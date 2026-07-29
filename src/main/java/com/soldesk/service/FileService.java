package com.soldesk.service;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.soldesk.config.UploadConfig;

/**
 * 업로드 파일 저장/삭제 전담 서비스.
 * 물리 파일만 다루고, 파일명(DB 저장값)을 반환한다.
 */
@Service
public class FileService {

    private static final Logger log = LoggerFactory.getLogger(FileService.class);

    /** 허용 확장자(소문자). 이미지 전용이므로 여기 없는 확장자는 저장하지 않는다. */
    private static final Set<String> ALLOWED_EXTENSIONS =
            new HashSet<>(Arrays.asList("jpg", "jpeg", "png", "gif", "webp"));

    /** 허용 MIME 타입. 브라우저가 보내는 값이라 위조 가능하므로 확장자 검사와 함께 쓴다. */
    private static final Set<String> ALLOWED_CONTENT_TYPES =
            new HashSet<>(Arrays.asList("image/jpeg", "image/png", "image/gif", "image/webp"));

    private static final Set<String> ADVERTISEMENT_EXTENSIONS =
            new HashSet<>(Arrays.asList("jpg", "jpeg", "png", "webp"));

    private static final Set<String> ADVERTISEMENT_CONTENT_TYPES =
            new HashSet<>(Arrays.asList("image/jpeg", "image/png", "image/webp"));

    private static final long ADVERTISEMENT_MAX_SIZE = 5L * 1024L * 1024L;

    @Autowired
    private UploadConfig uploadConfig;

    /**
     * 업로드 파일을 upload.path 에 UUID 파일명으로 저장한다.
     * @return DB 에 저장할 파일명. 파일이 없거나 비어 있으면 null.
     * @throws IllegalArgumentException 허용되지 않은 확장자/타입인 경우
     * @throws IOException 업로드 디렉터리를 쓸 수 없거나 저장에 실패한 경우
     */
    public String saveFile(MultipartFile multipartFile) throws IOException {
        if (multipartFile == null || multipartFile.isEmpty()) {
            return null;
        }
        return saveFileToDir(multipartFile, uploadConfig.getUploadPath());
    }

    /**
     * 광고 배너 전용 저장. 확장자/MIME뿐 아니라 파일 시그니처도 확인하고 5MB로 제한한다.
     */
    public String saveAdvertisementImage(MultipartFile multipartFile) throws IOException {
        if (multipartFile == null || multipartFile.isEmpty()) {
            return null;
        }
        if (multipartFile.getSize() > ADVERTISEMENT_MAX_SIZE) {
            throw new IllegalArgumentException("광고 이미지는 5MB 이하만 업로드할 수 있습니다.");
        }

        String original = multipartFile.getOriginalFilename();
        String ext = StringUtils.getFilenameExtension(original);
        if (ext == null) {
            throw new IllegalArgumentException("확장자가 없는 파일은 업로드할 수 없습니다.");
        }
        ext = ext.toLowerCase(Locale.ROOT);
        String contentType = multipartFile.getContentType();
        if (!ADVERTISEMENT_EXTENSIONS.contains(ext)
                || contentType == null
                || !ADVERTISEMENT_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))
                || !hasValidImageSignature(multipartFile, ext)) {
            throw new IllegalArgumentException("jpg, jpeg, png, webp 형식의 올바른 이미지 파일만 업로드할 수 있습니다.");
        }
        return saveValidatedFileToDir(multipartFile, uploadConfig.getUploadPath(), ext);
    }

    /**
     * upload.path 에서 파일을 삭제한다. null·빈 문자열·없는 파일은 무시.
     */
    public void deleteFile(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return;
        }
        deleteFileInDir(uploadConfig.getUploadPath(), fileName);
    }

    private String saveFileToDir(MultipartFile multipartFile, String uploadDirPath) throws IOException {
        String ext = resolveExtension(multipartFile);
        return saveValidatedFileToDir(multipartFile, uploadDirPath, ext);
    }

    private String saveValidatedFileToDir(MultipartFile multipartFile, String uploadDirPath, String ext)
            throws IOException {
        File dir = new File(uploadDirPath);
        // mkdirs()는 다른 스레드가 먼저 만들었을 때도 false를 돌려주므로 마지막에 다시 확인한다.
        if (!dir.isDirectory() && !dir.mkdirs() && !dir.isDirectory()) {
            throw new IOException("업로드 디렉터리를 만들 수 없습니다: " + dir.getAbsolutePath()
                    + " — app.properties 의 upload.path(또는 -Dupload.path)와 Tomcat 실행 계정의 쓰기 권한을 확인하세요.");
        }

        String fileName = UUID.randomUUID().toString() + "." + ext;
        multipartFile.transferTo(new File(dir, fileName));
        return fileName;
    }

    private boolean hasValidImageSignature(MultipartFile multipartFile, String ext) throws IOException {
        byte[] header = new byte[12];
        int length;
        try (InputStream input = multipartFile.getInputStream()) {
            length = input.read(header);
        }
        if (length < 4) {
            return false;
        }
        if ("jpg".equals(ext) || "jpeg".equals(ext)) {
            return (header[0] & 0xff) == 0xff && (header[1] & 0xff) == 0xd8
                    && (header[2] & 0xff) == 0xff;
        }
        if ("png".equals(ext)) {
            return length >= 8
                    && (header[0] & 0xff) == 0x89 && header[1] == 0x50
                    && header[2] == 0x4e && header[3] == 0x47
                    && header[4] == 0x0d && header[5] == 0x0a
                    && header[6] == 0x1a && header[7] == 0x0a;
        }
        return length >= 12
                && header[0] == 'R' && header[1] == 'I' && header[2] == 'F' && header[3] == 'F'
                && header[8] == 'W' && header[9] == 'E' && header[10] == 'B' && header[11] == 'P';
    }

    /**
     * 확장자와 MIME 타입을 화이트리스트로 검증하고, 정규화된 소문자 확장자를 돌려준다.
     * 저장 파일명은 UUID 로 새로 만들기 때문에 원본 파일명은 확장자 판별에만 쓴다.
     */
    private String resolveExtension(MultipartFile multipartFile) {
        String original = multipartFile.getOriginalFilename();
        String ext = StringUtils.getFilenameExtension(original);
        if (ext == null) {
            throw new IllegalArgumentException("확장자가 없는 파일은 업로드할 수 없습니다.");
        }
        ext = ext.toLowerCase(Locale.ROOT);
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            throw new IllegalArgumentException(
                    "이미지 파일만 업로드할 수 있습니다. (허용 확장자: jpg, jpeg, png, gif, webp)");
        }

        String contentType = multipartFile.getContentType();
        if (contentType == null
                || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase(Locale.ROOT))) {
            throw new IllegalArgumentException("이미지 파일만 업로드할 수 있습니다.");
        }
        return ext;
    }

    private void deleteFileInDir(String uploadDirPath, String fileName) {
        File file = new File(uploadDirPath, fileName);
        if (!file.exists()) {
            return;
        }
        if (!file.delete()) {
            log.warn("업로드 파일 삭제 실패: {}", file.getAbsolutePath());
        }
    }
}

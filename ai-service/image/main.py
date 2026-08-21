import base64
import io
import logging
import os
import time

import requests
from PIL import Image, ImageOps

from llm import get_image_llm, IMAGE_MODEL_NAME, IMAGE_QUALITY

logger = logging.getLogger(__name__)


def get_provider() -> str:
    """none(기본) | openai | sdcpp
    상담용 LLM_PROVIDER 와 분리
    """
    return os.getenv("IMAGE_PROVIDER", "none").strip().lower()


def is_enabled() -> bool:
    return get_provider() != "none"


def generate_image(
    prompt: str,
    reference_bytes: bytes,
    reference_media_type: str,
) -> tuple[str, str]:
    """참고 이미지를 편집해 (base64, mime) 로 돌려줌"""
    provider = get_provider()
    if provider == "openai":
        return _openai_edit(prompt, reference_bytes, reference_media_type)
    if provider == "sdcpp":
        return _sdcpp_edit(prompt, reference_bytes)
    raise RuntimeError(f"지원하지 않는 IMAGE_PROVIDER 입니다: {provider}")


def _openai_edit(
    prompt: str,
    reference_bytes: bytes,
    reference_media_type: str,
) -> tuple[str, str]:
    reference_base64 = base64.b64encode(reference_bytes).decode("utf-8")

    content = [
        {
            "type": "text",
            "text": prompt.strip(),
        },
        {
            "type": "image",
            "base64": reference_base64,
            "mime_type": reference_media_type,
        },
    ]

    image_tool = {
        "type": "image_generation",
        "quality": IMAGE_QUALITY,
        # edit 은 첨부 이미지를 고쳐 쓰고, create 는 백지에서 그림
        "action": "edit",
    }

    llm = get_image_llm()
    answer = llm.bind_tools([image_tool]).invoke([{"role": "user", "content": content}])

    for block in answer.content_blocks:
        if block.get("type") == "image" and block.get("base64"):
            return block["base64"], block.get("mime_type") or "image/png"

    raise RuntimeError("모델 응답에 생성된 이미지가 없습니다")


# ── 로컬 백엔드 (stable-diffusion.cpp sd-server) ──────────────────────────────

# 해상도를 올리면 생성 시간이 몇 배로 뜀
SDCPP_EDGE = int(os.getenv("SDCPP_IMAGE_EDGE", "512"))

# FLUX.2 Klein 은 4스텝 증류 모델이라 더 줘도 나아지지 않음
SDCPP_STEPS = int(os.getenv("SDCPP_STEPS", "4"))

# 증류 모델은 txt_cfg 를 1.0 으로 두고 distilled_guidance 로 조절함
SDCPP_TXT_CFG = 1.0
SDCPP_DISTILLED_GUIDANCE = 3.5

SDCPP_POLL_INTERVAL = 1.0
SDCPP_TIMEOUT_SECONDS = int(os.getenv("SDCPP_TIMEOUT_SECONDS", "180"))

# 첫 요청에는 가중치를 VRAM 으로 올리는 시간이 붙음
SDCPP_HTTP_TIMEOUT = 60

# 연결까지 이 시간을 넘기면 서버가 죽은 것
SDCPP_CONNECT_TIMEOUT = 3
_TIMEOUT = (SDCPP_CONNECT_TIMEOUT, SDCPP_HTTP_TIMEOUT)

# 색 얘기가 없어도 검정 머리가 갈색으로 바뀌는 현상이 3회 전부 재현됨
_COLOR_WORDS = ("색", "컬러", "염색", "탈색", "블리치", "color", "dye", "blond", "brown")

_LEAD = "keep original image"
_ACT_STYLE = "change hairstyle"
_ACT_COLOR = "change hair color"
_QUALITY = "detailed hair texture"
_PRESERVE = ("keep the same person, same face, same skin tone, "
             "same clothing and same background")
# 컬러 시술에까지 hairstyle only 를 붙이면 색을 바꾸지 말라는 말이 되어 서로 부딪힘
_ONLY_STYLE = "just change hairstyle only"
_ONLY_HAIR = "just change the hair only"
_KEEP_COLOR = "keep the original hair color"

_STYLE_TERMS = (
    ("히메컷", "hime cut hairstyle, straight hair, blunt bangs"),
    ("레이어드컷", "layered cut hairstyle, soft layers"),
    ("허쉬컷", "hush cut hairstyle, wolf cut, wispy layered ends"),
    ("샤기컷", "shaggy cut hairstyle, choppy textured layers"),
    ("투블럭컷", "two block haircut, undercut sides"),
    ("스포츠컷", "buzz cut, very short hair"),
    ("댄디컷", "dandy cut, neat side parted short hair"),
    ("픽시컷", "pixie cut hairstyle, very short crop"),
    ("숏컷", "short pixie cut hairstyle"),
    ("보브펌", "bob cut hairstyle with soft curls, chin length hair"),
    ("보브", "bob cut hairstyle, chin length hair"),
    ("단발", "short bob hairstyle, shoulder length hair"),
    ("긴머리", "long hair down past the shoulders"),
    ("장발", "long hair down past the shoulders"),
    ("생머리", "straight hair, no curls"),
    ("웨이브", "wavy hair, soft waves"),
    ("곱슬", "curly hair"),
    ("울프컷", "wolf cut hairstyle, shaggy layers"),
    ("태슬컷", "tassel cut, blunt short bob with straight ends"),
    ("포니테일", "ponytail hairstyle, hair tied back"),
    ("반삭", "buzz cut, very short hair"),
    ("삭발", "shaved head"),
    ("업스타일", "updo hairstyle, hair tied up in an elegant bun"),
    ("시스루뱅", "see through bangs, thin wispy fringe"),
    ("앞머리펌", "with soft curled side swept bangs"),
    ("앞머리", "with straight bangs, fringe"),
    ("히피펌", "hippie perm, wavy curly hair, beach waves"),
    ("셋팅펌", "setting perm, large soft curls"),
    ("디지털펌", "digital perm, loose curls at the ends"),
    ("가르마펌", "side part perm, side swept volume at the roots"),
    ("물결펌", "wavy perm, soft s curl waves"),
    ("볼륨매직", "sleek straight hair with root volume"),
    ("매직", "sleek straight hair"),
    ("다운펌", "flat hair pressed down, no volume"),
)

_COLOR_TERMS = (
    ("애쉬브라운", "ash brown hair color"),
    ("애쉬그레이", "ash grey hair color"),
    ("밀크브라운", "milk brown hair color, light warm brown"),
    ("새치커버", "dark brown hair color, no gray hair"),
    ("뿌리염색", "root touch up, dark roots"),
    ("발레아쥬", "balayage hair color, gradient highlights"),
    ("옴브레", "ombre hair color, dark roots fading to light ends"),
    ("블론드", "blonde hair color"),
    ("금발", "blonde hair color"),
    ("블리치", "bleached blonde hair"),
    ("탈색", "bleached blonde hair"),
    ("투톤", "two tone hair color"),
    ("브라운", "brown hair color"),
    ("블랙", "jet black hair color"),
    ("레드", "red hair color"),
    ("핑크", "pink hair color"),
    ("보라", "purple hair color"),
)

# 긴 것부터 봐야 '보브펌' 이 '보브' 로 먼저 잡히지 않음
_TERMS_SORTED = tuple(sorted(
    [(korean, english, False) for korean, english in _STYLE_TERMS]
    + [(korean, english, True) for korean, english in _COLOR_TERMS],
    key=lambda term: -len(term[0]),
))


def _sdcpp_base() -> str:
    return os.getenv("SDCPP_BASE_URL", "http://localhost:1234").rstrip("/")


def _match_terms(text: str) -> tuple[list[str], list[str]]:
    """한글 시술명을 영어 태그로 바꿈 — 걸리는 게 없으면 빈 목록"""
    packed = text.replace(" ", "")
    styles: list[str] = []
    colors: list[str] = []

    for korean, english, is_color in _TERMS_SORTED:
        if korean in packed:
            # 지우지 않으면 '보브펌' 이 '보브' 로 한 번 더 잡힘
            packed = packed.replace(korean, "")
            (colors if is_color else styles).append(english)

    return styles, colors


def _sdcpp_prompt(prompt: str) -> str:
    """얼굴이 다른 사람으로 밀리는 것과 머리색이 새는 것을 문구로 막음"""
    text = prompt.strip()
    styles, colors = _match_terms(text)

    wants_color = bool(colors) or any(word in text.lower() for word in _COLOR_WORDS)
    # 색만 고른 요청에 change hairstyle 을 붙이면 시키지도 않은 컷까지 바뀜
    # 아무것도 안 걸리면 컷 요청으로 봄 — 이 화면에서 들어오는 대부분이 그쪽임
    wants_style = bool(styles) or not wants_color

    actions = []
    if wants_style:
        actions.append(_ACT_STYLE)
    if wants_color:
        actions.append(_ACT_COLOR)

    tags = styles + colors
    # 사전에 걸리는 게 없으면 적은 것을 그대로 씀 — 영어로 적었을 수 있음
    parts = [_LEAD, *actions, ", ".join(tags) if tags else text, _QUALITY, _PRESERVE]

    if wants_color:
        parts.append(_ONLY_HAIR)
    else:
        parts += [_ONLY_STYLE, _KEEP_COLOR]
    return ", ".join(parts)


def _normalize_reference(reference_bytes: bytes) -> str:
    """참고 이미지를 SDCPP_EDGE 정사각 PNG 로 맞춰 data URL 로 돌려줌

    잘라내지 않고 여백을 채움 — 전신 사진이 들어오면 가운데를 자를 때 머리가 통째로
    날아가는데, 바꿔 보려는 게 머리라 그쪽 실패가 훨씬 나쁨
    """
    source = Image.open(io.BytesIO(reference_bytes))
    # 안 풀면 세로로 찍은 폰 사진이 눕혀진 채로 들어감
    image = ImageOps.exif_transpose(source).convert("RGB")
    image.thumbnail((SDCPP_EDGE, SDCPP_EDGE), Image.LANCZOS)

    canvas = Image.new("RGB", (SDCPP_EDGE, SDCPP_EDGE), (255, 255, 255))
    canvas.paste(image, ((SDCPP_EDGE - image.width) // 2,
                         (SDCPP_EDGE - image.height) // 2))

    buffer = io.BytesIO()
    canvas.save(buffer, format="PNG")
    # sd-server 는 순수 base64 가 아니라 data URL 을 받음
    return "data:image/png;base64," + base64.b64encode(buffer.getvalue()).decode("utf-8")


def _sdcpp_edit(prompt: str, reference_bytes: bytes) -> tuple[str, str]:
    base = _sdcpp_base()

    # init_image 가 아니라 ref_images 여야 함 — init_image 는 원본에 노이즈를 씌워
    # 다시 그리는 고전 img2img 라 얼굴이 남지 않음. cli 의 -r 에 해당하는 것이 이쪽
    payload = {
        "prompt": _sdcpp_prompt(prompt),
        "ref_images": [_normalize_reference(reference_bytes)],
        "width": SDCPP_EDGE,
        "height": SDCPP_EDGE,
        "batch_count": 1,
        "sample_params": {
            "sample_method": "euler",
            "sample_steps": SDCPP_STEPS,
            "scheduler": "default",
            "guidance": {
                "txt_cfg": SDCPP_TXT_CFG,
                "distilled_guidance": SDCPP_DISTILLED_GUIDANCE,
            },
        },
        "output_format": "png",
    }

    accepted = requests.post(f"{base}/sdcpp/v1/img_gen", json=payload,
                             timeout=_TIMEOUT)
    accepted.raise_for_status()
    job = accepted.json()

    job_id = job.get("id")
    if not job_id:
        raise RuntimeError(f"sd-server 가 작업 번호를 주지 않았습니다: {job}")

    return _sdcpp_wait(base, job_id)


def _sdcpp_wait(base: str, job_id: str) -> tuple[str, str]:
    """완료될 때까지 폴링함

    sd-server 는 202 만 주고 끝나므로 여기서 기다려 스프링에는 동기로 보이게 함
    512 가 20초대라 버티는 것이고, 해상도를 올리면 성립하지 않음
    """
    deadline = time.monotonic() + SDCPP_TIMEOUT_SECONDS

    while True:
        if time.monotonic() > deadline:
            _sdcpp_cancel(base, job_id)
            raise TimeoutError(f"sd-server 작업이 {SDCPP_TIMEOUT_SECONDS}초 안에 끝나지 않았습니다")

        polled = requests.get(f"{base}/sdcpp/v1/jobs/{job_id}",
                              timeout=_TIMEOUT)
        polled.raise_for_status()
        state = polled.json()
        status = state.get("status")

        if status == "completed":
            images = (state.get("result") or {}).get("images") or []
            if not images or not images[0].get("b64_json"):
                raise RuntimeError("sd-server 응답에 이미지가 없습니다")
            return images[0]["b64_json"], "image/png"

        if status in ("failed", "cancelled"):
            raise RuntimeError(f"sd-server 작업이 {status} 로 끝났습니다: {state.get('error')}")

        time.sleep(SDCPP_POLL_INTERVAL)


def _sdcpp_cancel(base: str, job_id: str) -> None:
    """안 지우면 우리가 포기한 뒤에도 GPU 를 계속 붙잡고 있음"""
    try:
        requests.post(f"{base}/sdcpp/v1/jobs/{job_id}/cancel", timeout=_TIMEOUT)
    except Exception:
        logger.warning("sd-server 작업을 취소하지 못했습니다: %s", job_id)

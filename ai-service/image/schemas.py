from pydantic import BaseModel, ConfigDict, Field


# 스프링으로 돌려주는 이미지 편집 응답
class ImageResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)
    image_base64: str = Field(alias="imageBase64")
    media_type: str = Field(alias="mediaType")
    prompt: str
    source: str
    model: str

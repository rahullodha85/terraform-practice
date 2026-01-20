from functools import lru_cache

from pydantic.v1 import BaseSettings

class Config(BaseSettings):
    ENV: str = 'dev'
    HOST: str = '0.0.0.0'
    PORT: int = 8000
    SERVICE_NAME: str = ''
    API_PREFIX: str = ''
    API2_URL: str = 'http://fast-api-2:8001/health'

@lru_cache()
def get_config():
    return Config()
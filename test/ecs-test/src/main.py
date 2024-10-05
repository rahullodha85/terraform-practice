from fastapi import FastAPI

from config.config import get_config

config = get_config()

app = FastAPI(
    # title=app_config.api_name,
    # description=app_config.api_name,
    # docs_url=f'{app_config.api_prefix}/docs',
    # redoc_url=f'{app_config.api_prefix}/redoc',
    # openapi_url=f'{app_config.api_prefix}/openapi.json',
    # root_path = '',
    # on_startup=[get_all_secrets]
)

@app.get('/')
def health_check():
    return {
        'status': 'ok',
        'environment': config.ENV
    }

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host=config.HOST, port=config.PORT)
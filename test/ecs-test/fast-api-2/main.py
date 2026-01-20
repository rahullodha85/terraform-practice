from fastapi import FastAPI, APIRouter

from config.config import get_config

config = get_config()

app = FastAPI(
    # root_path=config.API_PREFIX
    # title=app_config.api_name,
    # description=app_config.api_name,
    # docs_url=f'{app_config.api_prefix}/docs',
    # redoc_url=f'{app_config.api_prefix}/redoc',
    # openapi_url=f'{app_config.api_prefix}/openapi.json',
    # on_startup=[get_all_secrets]
)


@app.get('/')
@app.get('/health')
def health_check():
    return {
        'status': 'ok',
        'environment': config.ENV,
        'message': f'This is service: {config.SERVICE_NAME}'
    }

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host=config.HOST, port=config.PORT)
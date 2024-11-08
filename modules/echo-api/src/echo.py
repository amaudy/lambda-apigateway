import json

def handler(event, context):
    # Get the request body
    body = event.get('body', '')
    if body:
        try:
            body = json.loads(body)
        except:
            pass
    
    # Prepare the response
    response = {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': 'Echo API Response',
            'input': body
        })
    }
    
    return response 
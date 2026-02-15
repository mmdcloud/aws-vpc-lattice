def lambda_handler(event, context):
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>My Lambda HTML Page</title>
        <style>
            body { 
                font-family: Arial, sans-serif; 
                background-color: #f4f4f4; 
                text-align: center; 
                padding-top: 50px; 
            }
            .card {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 4px 10px rgba(0,0,0,0.1);
                display: inline-block;
            }
            h1 { color: #2c3e50; }
        </style>
    </head>
    <body>
        <div class="card">
            <h1>Hello from AWS Lambda 🚀</h1>
            <p>This HTML is rendered directly from a Python Lambda function.</p>
        </div>
    </body>
    </html>
    """

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/html"
        },
        "body": html_content
    }

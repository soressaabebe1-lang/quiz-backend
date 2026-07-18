from project import create_app
from flask_jwt_extended import create_access_token
import io
from openpyxl import Workbook

app = create_app()
with app.test_request_context():
    token = create_access_token(identity=1, additional_claims={'is_admin': True})

with app.test_client() as client:
    workbook = Workbook()
    sheet = workbook.active
    sheet.title = 'Questions'
    sheet.append(['Question', 'A', 'B', 'C', 'D', 'Answer'])
    sheet.append(['What is 2+2?', '3', '4', '5', '6', 'B'])
    buffer = io.BytesIO()
    workbook.save(buffer)
    buffer.seek(0)
    response = client.post(
        '/question/import',
        data={'file': (buffer, 'questions.xlsx')},
        content_type='multipart/form-data',
        headers={'Authorization': f'Bearer {token}'}
    )
    print(response.status_code)
    print(response.get_json())

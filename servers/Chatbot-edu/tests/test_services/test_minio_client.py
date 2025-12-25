import pytest
from unittest.mock import MagicMock, patch
from minio.error import S3Error
from services.minio_client import get_minio_client, download_pdf_files, upload_pdf_to_minio
from core.config import settings

@pytest.fixture
def mock_minio():
    with patch('services.minio_client.Minio') as mock:
        yield mock

def test_get_minio_client_success(mock_minio):
    """Test successful creation of MinIO client"""
    client = get_minio_client()
    mock_minio.assert_called_once()
    assert client == mock_minio.return_value

def test_download_pdf_files_success(mock_minio, tmp_path):
    """Test successful download of PDF files"""
    mock_client = mock_minio.return_value
    mock_client.bucket_exists.return_value = True
    
    # Mock list_objects response
    mock_obj1 = MagicMock()
    mock_obj1.object_name = "course1.pdf"
    mock_obj1.size = 1000
    
    mock_obj2 = MagicMock()
    mock_obj2.object_name = "image.png" # Should be ignored
    
    mock_client.list_objects.return_value = [mock_obj1, mock_obj2]
    
    output_dir = str(tmp_path)
    files = download_pdf_files(output_dir)
    
    assert len(files) == 1
    assert files[0].endswith("course1.pdf")
    mock_client.fget_object.assert_called_once()

def test_download_pdf_files_bucket_not_found(mock_minio):
    """Test behavior when bucket does not exist"""
    mock_client = mock_minio.return_value
    mock_client.bucket_exists.return_value = False
    
    with pytest.raises(ValueError, match="Bucket .* non trouvé"):
        download_pdf_files()

def test_download_pdf_files_s3_error(mock_minio):
    """Test handling of S3Error"""
    mock_client = mock_minio.return_value
    mock_client.bucket_exists.return_value = True
    mock_client.list_objects.side_effect = S3Error("code", "message", "resource", "request_id", "host_id", "response")
    
    with pytest.raises(S3Error):
        download_pdf_files()

def test_upload_pdf_to_minio_success(mock_minio, tmp_path):
    """Test successful upload"""
    mock_client = mock_minio.return_value
    mock_client.bucket_exists.return_value = False # Should trigger make_bucket
    
    file_path = tmp_path / "test.pdf"
    file_path.touch()
    
    result = upload_pdf_to_minio(str(file_path))
    
    assert result is True
    mock_client.make_bucket.assert_called_once()
    mock_client.fput_object.assert_called_once()

def test_upload_pdf_to_minio_failure(mock_minio, tmp_path):
    """Test upload failure handled gracefully"""
    mock_client = mock_minio.return_value
    mock_client.bucket_exists.return_value = True
    mock_client.fput_object.side_effect = S3Error("code", "message", "resource", "request_id", "host_id", "response")
    
    file_path = tmp_path / "test.pdf"
    file_path.touch()
    
    result = upload_pdf_to_minio(str(file_path))
    
    assert result is False

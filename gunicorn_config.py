bind = "0.0.0.0:8080"
workers = 1
max_requests = 1  # Limit the number of requests per worker
worker_class = "gthread"  # Use the gthread worker class for threading support
capture_output = False  # Disable capturing worker output

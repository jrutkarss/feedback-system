# Use official lightweight Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Set work directory
WORKDIR /app

# Install system dependencies needed for PostgreSQL (psycopg2)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Collect static files for WhiteNoise
RUN python manage.py collectstatic --noinput
RUN docker compose exec web python manage.py makemigrations
RUN docker compose exec web python manage.py migrate

# migrate the database 

# Expose the application port
EXPOSE 8000

# Run the application using Gunicorn
CMD ["gunicorn", "quickrate.wsgi:application", "--bind", "0.0.0.0:8000"]

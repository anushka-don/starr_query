FROM python:3.13-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-wsgi-py3 \
    libmariadb-dev \
    libmariadb3 \
    gcc \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Fix the ServerName warning globally
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Python dependencies
WORKDIR /var/www/starr_query
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Application source code
COPY app.py        .
COPY templates/    templates/
COPY static/       static/
COPY starr_query.wsgi .

# Apache config
COPY apache/starr_query.conf /etc/apache2/sites-available/starr_query.conf

# Enable mod_wsgi, headers, our site; disable default
RUN a2enmod wsgi headers \
    && a2ensite starr_query \
    && a2dissite 000-default

EXPOSE 80

# Env var placeholders — BU injects real values at runtime via docker-compose
ENV DB_HOST=""
ENV DB_USER=""
ENV DB_PASS=""
ENV DB_NAME=""
ENV DB_PORT="3306"

CMD ["apache2ctl", "-D", "FOREGROUND"]


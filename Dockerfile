FROM python:3.11-slim

WORKDIR /app

# ONE LAYER: Install Chrome + matching Chromedriver (2025 way - no dead packages)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg \
        unzip \
        libglib2.0-0 \
        libnss3 \
        libxss1 \
        libxtst6 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libgtk-3-0 \
        libdrm2 \
        libgbm1 \
        libasound2 \
        fonts-liberation \
        xdg-utils \
        && wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
        && apt-get install -y ./google-chrome-stable_current_amd64.deb || apt --fix-broken install -y \
        && CHROME_VERSION=$(google-chrome --version | awk '{print $3}' | cut -d '.' -f1) \
        && wget -O /tmp/chromedriver.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_VERSION}.0.0.0/linux64/chromedriver-linux64.zip \
        && unzip /tmp/chromedriver.zip -d /tmp \
        && mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver \
        && chmod +x /usr/local/bin/chromedriver \
        && rm -rf /var/lib/apt/lists/* /tmp/* google-chrome-stable_current_amd64.deb


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["robot", "--outputdir", "results", "tests/"]

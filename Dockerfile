FROM python:3.11-slim

WORKDIR /app

# ONE LAYER: Install Chrome + matching Chromedriver (2025 way - no dead packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg wget unzip \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && CHROME_MAJOR=$(google-chrome --version | cut -d' ' -f3 | cut -d'.' -f1) \
    && wget -O /tmp/chromedriver.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${CHROME_MAJOR}.0.0.0/linux64/chromedriver-linux64.zip \
    && unzip /tmp/chromedriver.zip -d /tmp \
    && mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm -rf /var/lib/apt/lists/* /tmp/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["robot", "--outputdir", "results", "tests/"]

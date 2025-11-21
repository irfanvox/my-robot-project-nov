FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Modern Chrome + Chromedriver install (no apt-key!) ---
RUN apt-get update && apt-get install -y \
    ca-certificates curl gnupg unzip \
    && curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && CHROME_MAJOR=$(google-chrome --version | sed -E 's/.* ([0-9]+)(\.[0-9]+){3}.*/\1/') \
    && CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR}") \
    && curl -s "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" -o /tmp/chromedriver.zip \
    && unzip /tmp/chromedriver.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/chromedriver \
    && rm -rf /var/lib/apt/lists/*

COPY . .

# Run in headless mode + disable GPU + no sandbox (CI needs this)
#ENV ROBOT_OPTIONS=--variable BROWSER:chrome --variable HEADLESS:True
CMD ["bash", "robot-docker.sh"]

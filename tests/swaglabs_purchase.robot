*** Settings ***
Library     SeleniumLibrary
Library     OperatingSystem

*** Variables ***
${URL}             https://www.saucedemo.com/
${BROWSER}         chrome
${USERNAME}        standard_user
${PASSWORD}        secret_sauce
${INVALID_USER}    locked_out_user

*** Test Cases ***
TC_01 - Complete E2E Purchase flow
    [Tags]    E2E regression
    Open SauceDemo With Headless Chrome
    Login    ${USERNAME}    ${PASSWORD}
    Sort Products High To Low
    Open Social Link And Return    Facebook
    Add Items To Cart
    Verify Cart Badge    2
    Go To Cart And Verify Items
    Checkout And Complete Purchase
    Verify Order Success

TC002 - Negative Login Test
    [Tags]    negative
    # CHANGED: Use the keyword that sets up Headless options, otherwise this fails in Docker
    Open SauceDemo With Headless Chrome
    Input Text    id=user-name    ${INVALID_USER}
    Input Text    id=password     ${PASSWORD}
    Click Button  id=login-button
    Element Should Contain    xpath=//h3[@data-test="error"]    Epic sadface: Sorry, this user has been locked out.
    Close Browser

*** Keywords ***
Open SauceDemo With Headless Chrome
    [Documentation]    Initializes Chrome with options required for Docker (Headless, No Sandbox)
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    
    # --headless=new is the modern standard for Chrome 109+
    Call Method    ${chrome_options}    add_argument    --headless=new
    
    # --no-sandbox is REQUIRED for running as root in Docker
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    
    # --disable-dev-shm-usage prevents crashes due to limited shared memory in Docker
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    
    # Sets the window size directly in options, avoiding the 'Set Window Size' keyword error
    Call Method    ${chrome_options}    add_argument    --window-size\=1920,1080
    
    # Open Browser using the created options
    Open Browser    ${URL}    chrome    options=${chrome_options}

Login
    [Arguments]    ${user}    ${pass}
    Input Text    id=user-name    ${user}
    Input Text    id=password     ${pass}
    Click Button  id=login-button
    Wait Until Page Contains Element    xpath=//div[@id="inventory_container"]    10s

Sort Products High To Low
    Select From List By Value    xpath=//select[@data-test="product-sort-container"]    hilo

Open Social Link And Return
    [Arguments]    ${link_text}
    Click Link    xpath=//a[text()="${link_text}"]
    Switch Window    NEW
    Wait For Page Fully Loaded
    # Capturing screenshot to verify window switch worked
    Capture Page Screenshot    ${link_text.lower()}_screen.png
    Close Window
    Switch Window    MAIN

Add Items To Cart
    Click Button    id=add-to-cart-sauce-labs-onesie
    Click Button    id=add-to-cart-sauce-labs-bike-light

Verify Cart Badge
    [Arguments]    ${expected}
    Element Text Should Be    xpath=//span[@class="shopping_cart_badge"]    ${expected}

Go To Cart And Verify Items
    Click Link    xpath=//a[@class="shopping_cart_link"]
    Element Text Should Be    xpath=//div[@data-test="inventory-item-name" and text()="Sauce Labs Onesie"]    Sauce Labs Onesie

Checkout And Complete Purchase
    Click Button    id=checkout
    Input Text    id=first-name     Irfan
    Input Text    id=last-name      shaik
    Input Text    id=postal-code    500055
    Click Button    id=continue
    Element Should Contain    xpath=//div[@class="summary_total_label"]    Total
    Click Button    id=finish

Verify Order Success
    Element Should Contain    xpath=//h2[normalize-space()="Thank you for your order!"]    Thank you for your order!

Wait For Page Fully Loaded
    Wait Until Keyword Succeeds    20s    1s    Execute JavaScript    return document.readyState === 'complete'

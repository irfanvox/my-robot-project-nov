*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}             https://www.saucedemo.com/
${BROWSER}         chrome
${USERNAME}        standard_user
${PASSWORD}        secret_sauce
${INVALID_USER}    locked_out_user

*** Test Cases ***
TC_01 - Complete E2E Purchase flow
    [Tags]    E2E    regression
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
    Open Browser    ${URL}    ${BROWSER}
    Input Text    id=user-name    ${INVALID_USER}
    Input Text    id=password     ${PASSWORD}
    Click Button  id=login-button
    Element Should Contain    xpath=//h3[@data-test="error"]    Epic sadface: Sorry, this user has been locked out.
    Close Browser

*** Keywords ***
Open SauceDemo With Headless Chrome
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless=chrome
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --disable-gpu
    Call Method    ${options}    add_argument    --remote-debugging-port=9222
    Call Method    ${options}    add_argument    --window-size=1920,1080
    Call Method    ${options}    add_experimental_option    excludeSwitches    ${{["enable-automation"]}}
    Call Method    ${options}    add_experimental_option    useAutomationExtension    ${False}

    ${prefs}=    Create Dictionary
    ...    credentials_enable_service=${False}
    ...    profile.password_manager_enabled=${False}
    ...    profile.password_manager_leak_detection=${False}
    ...    autofill.profile_enabled=${False}
    ...    autofill.credit_card_enabled=${False}
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}

    Open Browser    ${URL}    chrome    options=${options}
    # No Maximize Browser Window needed in headless with window-size

Login
    [Arguments]    ${user}    ${pass}
    Input Text     id=user-name    ${user}
    Input Text     id=password     ${pass}
    Click Button   id=login-button
    Wait Until Page Contains Element    xpath=//div[@id="inventory_container"]    10s

Sort Products High To Low
    Select From List By Value    xpath=//select[@data-test="product-sort-container"]    hilo

Open Social Link And Return
    [Arguments]    ${link_text}
    Click Link    xpath=//a[text()="${link_text}"]
    Switch Window    NEW
    Wait For Page Fully Loaded
    Press Keys    None    ESC
    Capture Page Screenshot    ${link_text.lower()}_screen.png
    Close Window
    Switch Window    MAIN
    Press Keys    None    ESC
    Press Keys    None    ESC

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
    Input Text      id=first-name     Irfan
    Input Text      id=last-name      shaik
    Input Text      id=postal-code    500055
    Click Button    id=continue               # ← fixed: it's a <button>, not <input>
    Element Should Contain    xpath=//div[@class="summary_total_label"]    Total
    Click Button    id=finish
    Element Should Contain    xpath=//h2[normalize-space()="Thank you for your order!"]    Thank you for your order!

Wait For Page Fully Loaded
    Wait Until Keyword Succeeds    20s    1s    Execute JavaScript    return document.readyState === 'complete'

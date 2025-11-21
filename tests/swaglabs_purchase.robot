*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}    https://www.saucedemo.com/
${BROWSER}    chrome
${USERNAME}    standard_user
${PASSWORD}    secret_sauce
${INVALID_USER}    locked_out_user

*** Test Cases ***
TC_01 - Complete E2E Purchase flow
	[Tags]    E2E    regression
    # Create ChromeOptions object using Python
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --headless=chrome
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --disable-gpu
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

	Maximize Browser Window 
	
	#Login
	Input Text    id=user-name    ${USERNAME}
	Input Text    id=password    ${PASSWORD}
	Click Button    id=login-button
	
	#Sort by Hilo
	Select From List By Value    xpath=//select[@data-test="product-sort-container"]    hilo
	Page Should Contain Image    xpath=//img[@alt='Sauce Labs Onesie']
	Click Link    xpath=//a[text()="Facebook"]
	Switch Window    NEW
	Wait For Page Fully Loaded
	Press Keys    None    ESC
    Capture Page Screenshot    face_book_screen.png
	Close Window
	Switch Window    Main
	Press Keys    None    ESC
    Press Keys    None    ESC
    Click Button    id=add-to-cart-sauce-labs-onesie
	Click Button    id=add-to-cart-sauce-labs-bike-light
    Element Text Should Be    xpath=//span[@class='shopping_cart_badge']    2
    Click Link    xpath=//a[@class="shopping_cart_link"]    
    Element Text Should Be    xpath=//div[@data-test="inventory-item-name" and text()="Sauce Labs Onesie"]    Sauce Labs Onesie
    Click Button    id=remove-sauce-labs-bike-light
    Click Button    id=checkout

    Input Text    id=first-name    Irfan
    Input Text    id=last-name    shaik
    Input Text    id=postal-code    500055

    Click Button    xpath=//input[@type="submit" or id=continue]

    Element Should Contain    xpath=//div[@class="summary_total_label"]    Total

    Click Button    id=finish

    Element Should Contain    //*[@id="checkout_complete_container"]/h2    Thank you for your order!


TC002 - Negative Login Test
    [Tags]    negative
    Open Browser    ${URL}    ${BROWSER}
    Input Text    id=user-name    ${INVALID_USER}
    Input Text    id=password    {PASSWORD}
    Click Button    id=login-button
    Element Should Contain    xpath=//h3[@data-test="error"]    Epic sadface
    Close Browser

*** Keywords ***
Wait For Page Fully Loaded
	Wait Until Keyword Succeeds    20s    1s    Execute JavaScript    return document.readyState=='complete'

*** Settings ***
Library           SeleniumLibrary
Library           DateTime
Library           Collections
Library           String
Suite Teardown    Close All Browsers


*** Variables ***
${url}                                  https://test.com/sign-in
${browser}                              chrome

# LOGIN 
${locator_input_email}                  id=email
${locator_input_pass}                   id=password
${locator_btn_Login}                    xpath=/html/body/app-root/layout/empty-layout/div/div/auth-sign-in/div/div[2]/div/form/button
${locator_btn_menu}                     xpath=/html/body/app-root/layout/classy-layout/div/div[1]/button
${locator_select_Log}                   xpath=//vertical-navigation-basic-item//a[contains(@class, 'vertical-navigation-item') and .//span[contains(text(), 'Log การใช้งาน Web Application')]]
# เลือกวันที่
${START_DATE}                           xpath=//span[contains(text(),'วันที่เริ่มต้นในการค้นหา')]/ancestor::div[contains(@class, 'mat-mdc-chip-action')]
${END_DATE}                             xpath=//span[contains(text(),'วันที่สิ้นสุดในการค้นหา')]/ancestor::div[contains(@class, 'mat-mdc-chip-action')]
${START_DATE_TEXT}                      xpath=//mat-chip[contains(.,'วันที่เริ่มต้นในการค้นหา')]//span[contains(@class,'mdc-evolution-chip__text-label')]
${END_DATE_TEXT}                        xpath=//mat-chip[contains(.,'วันที่สิ้นสุดในการค้นหา')]//span[contains(@class,'mdc-evolution-chip__text-label')]
${locator_date}                         xpath=//*[@id="mat-mdc-chip-5"]/span[3]/div
# ค้นหาตัวกรองเพิ่มเติม
${locator_btn_filter}                   xpath=/html/body/app-root/layout/classy-layout/div/div[2]/company-admin-logs-activity/company-admin-logs-activity-list/div/chip-filter/div/div/mat-chip-listbox/span/button
${locator_select_filter}                xpath=//mat-select[@placeholder='ประเภทตัวกรองที่อนุญาต']
${locator_select_function}              xpath=//mat-option[contains(., 'ฟังก์ชัน')]
${locator_input_filter}                 xpath=//mat-form-field[contains(@class, 'mat-mdc-form-field')]//input[@type='text']
${locator_select_operation}             xpath=//mat-option[contains(., 'การดำเนินการ')]
${locator_btn_search}                   xpath=//button[.//span[normalize-space(text())='เพิ่ม']]
${locator_btn_cancel}                   xpath=//mat-icon[@role='button' and @data-mat-icon-name='minus-circle']
# ข้อมูลในตาราง
${locator_no_data_message}              xpath=//div[contains(@class, 'p-8') and contains(@class, 'sm:p-16') and contains(@class, 'text-4xl')]
${locator_data_table}                   xpath=//div[contains(@class, 'company-admin-logs-activity-grid')]
${locator_data_table_text}              xpath=//div[contains(@class, 'truncate') and contains(text(), 'ลงชื่อเข้าใช้สำเร็จ')]
# Sorting Column
${locator_sorting_date}                 xpath=//div[contains(@class, 'mat-sort-header') and .//div[contains(text(), 'วันที่ดำเนินการ')]]
${locator_table_date}                   css=.company-admin-logs-activity-grid div:nth-child(6)
# Operation
${locator_sorting_operation}            xpath=//div[contains(@class, 'mat-sort-header') and .//div[contains(text(), 'การดำเนินการ')]]
${locator_table_operation}              css=.company-admin-logs-activity-grid div:nth-child(4)
${locator_table_sort}                   css=.mat-sort-header-arrow
# Number
${locator_sorting_num}                  xpath=//div[contains(@class, 'mat-sort-header') and .//div[contains(text(), '#')]]





*** Keywords ***
Open Test
    [Documentation]    เปิดใช้งานเว็บไซต์ Test
    Set Selenium Speed    0.2s
    Open Browser          ${url}      ${browser}
    Maximize Browser Window

Login Test - Pass
    [Documentation]    ตรวจสอบการเข้าสู่ระบบ
    Open Test
    Wait Until Page Contains                     เข้าสู่แพลตฟอร์ม Test
    Input Text         ${locator_input_email}    test@gmail.com
    Input Text         ${locator_input_pass}     Password
    Wait Until Element Is Visible                ${locator_btn_Login}
    Click Button       ${locator_btn_Login}
    Wait Until Element Is Visible                ${locator_btn_menu}

Open Log application
    [Documentation]    ตรวจสอบการเปิดหน้า Log Activity
    Login Test - Pass
    Wait Until Element Is Visible    ${locator_select_Log}
    Click Element                    ${locator_select_Log}
    Wait Until Page Contains         Activity Log from Web Application

Search Select Date
    [Documentation]    ตรวจสอบการเลือกวันเดือนปีในการค้นหา และตรวจสอบข้อความในตาราง
    [Arguments]    ${select_date}    ${date_year}    ${date_month}    ${date}

    # สร้างเงื่อนไข หากข้อความตรงกับอันไหน ให้ทำอันนั้น
    IF    '${select_date}' == "วันที่เริ่ม"
           # คลิกวันที่เริ่ม เพื่อที่จะแสดงปฎิทิน
           Click Element    ${START_DATE}
    ELSE IF    '${select_date}' == "วันที่จบ"
            # คลิกวันที่จบ เพื่อที่จะแสดงปฎิทิน
            Click Element    ${END_DATE}
    END

    # คลิกปุ่มที่ให้เลือกเดือน และปี
    Click Element    xpath=//button[contains(@aria-label, 'Choose month and year')]
    # เลือกปี
    Click Element    xpath=//td//div[contains(text(), '${date_year}')]
    # เลือกเดือน
    Click Element    xpath=//td//div[contains(text(), '${date_month}')]
    # เลือกวันที่
    Click Element    xpath=//td//div[contains(text(), '${date}')]
    # รอให้ปฏิทินปิด
    Wait Until Element Is Not Visible     xpath=//mat-datepicker-content
    
    # สร้างรูปแบบวันที่ที่คาดหวัง
    ${Expected_date}=    Set Variable     ${date_year}-${date_month}-${date}
    # รอจนกว่า locator จะขึ้นมา
    Wait Until Element Is Visible         ${locator_btn_filter} 

    # กำหนด dictionary สำหรับแปลงเดือนเป็นตัวเลข เพื่อนำมาตรวจสอบ
    ${month_map}=    Create Dictionary    JAN=01    FEB=02    MAR=03    APR=04    MAY=05    JUN=06    JUL=07    AUG=08    SEP=09    OCT=10    NOV=11    DEC=12
    # แปลงเดือนเป็นหมายเลข
    ${month_number}=    Get From Dictionary    ${month_map}    ${date_month}
    # สร้างรูปแบบวันที่ที่คาดหวัง
    ${Expected_date}=    Set Variable        ${date_year}-${month_number}-${date}
    
    # ตรวจสอบวันที่เริ่มต้นในการค้นหา และสร้างเงื่อนไขในการตรวจสอบข้อมูลใน Table
    IF    '${select_date}' == "วันที่เริ่ม"
        # ดึงข้อความจาก START_DATE_TEXT โดยใช้คำสั่ง Get Text และเก็บผลลัพธ์ไว้ในตัวแปร actual_date
        ${actual_date}=    Get Text          ${START_DATE_TEXT}
        # ตรวจสอบว่าข้อความใน actual_date มีค่าวันที่ตรงกับ Expected_date หรือไม่
        Should Contain     ${actual_date}    ${Expected_date}

        # ตรวจสอบสถานะว่าตารางที่มีข้อความ ${locator_data_table} ปรากฏหรือไม่ ภายในเวลา 10 วินาที และเก็บสถานะนั้นไว้ในตัวแปร ${status}
        ${status}=    Run Keyword And Return status     Wait Until Element Is Visible    ${locator_data_table}    timeout=5s
        # กรณีเข้าเงื่อนไขให้ตรวจสอบที่ IF หากไม่เข้าเงื่อนไขให้ตรวจสอบที่ ELSE
        IF    ${status}
            # รอจนกว่าข้อความใน ${locator_data_table_text} จะปรากฏ
            Wait Until Element Is Visible    ${locator_data_table_text}    timeout=5s
            # ตรวจสอบว่ามี ${locator_data_table_text} นั้นจริง
            Element Should Be Visible    ${locator_data_table_text}
            # ดึงข้อความใน ${locator_data_table_text} มาเก็บไว้ใน ${login_text}
            ${data_text}=    Get Text    ${locator_data_table_text}
            # ตรวจสอบข้อความว่าเท่ากับ "ลงชื่อเข้าใช้สำเร็จ" หรือไม่
            Should Be Equal    ${data_text}    ลงชื่อเข้าใช้สำเร็จ
        ELSE
            # ถ้า ${status} เป็น False รอจนกว่า ${locator_no_data_message} ปรากฏภายใน 5 วินาที
            Wait Until Element Is Visible    ${locator_no_data_message}    timeout=5s
            # ตรวจสอบ ${locator_no_data_message} นั้นมีอยู่จริง
            Element Should Be Visible    ${locator_no_data_message}
            # ดึงข้อความใน ${locator_no_data_message} มาเก็บไว้ใน ${message}
            ${message}=    Get Text    ${locator_no_data_message}
            # ตรวจสอบข้อความว่าเท่ากับ "ไม่พบข้อมูลที่ต้องการค้นหา" หรือไม่
            Should Be Equal    ${message}    ไม่พบข้อมูลที่ต้องการค้นหา!
        END
    END
    # ตรวจสอบวันที่สิ้นสุดในการค้นหา และสร้างเงื่อนไขในการตรวจสอบข้อมูลใน Table
    IF    '${select_date}' == "วันที่จบ"
        ${actual_date}=    Get Text          ${END_DATE_TEXT}
        Should Contain     ${actual_date}    ${Expected_date}
        
        # ตรวจสอบสถานะว่าตารางที่มีข้อความ ${locator_data_table} ปรากฏหรือไม่ ภายในเวลา 10 วินาที และเก็บสถานะนั้นไว้ในตัวแปร ${status}
        ${status}=    Run Keyword And Return status     Wait Until Element Is Visible    ${locator_data_table}    timeout=5s
        # กรณีเข้าเงื่อนไขให้ตรวจสอบที่ IF หากไม่เข้าเงื่อนไขให้ตรวจสอบที่ ELSE
        IF    ${status}
            # รอจนกว่าข้อความใน ${locator_data_table_text} จะปรากฏ
            Wait Until Element Is Visible    ${locator_data_table_text}    timeout=5s
            # ตรวจสอบว่ามี ${locator_data_table_text} นั้นจริง
            Element Should Be Visible    ${locator_data_table_text}
            # ดึงข้อความใน ${locator_data_table_text} มาเก็บไว้ใน ${login_text}
            ${data_text}=    Get Text    ${locator_data_table_text}
            # ตรวจสอบข้อความว่าเท่ากับ "ลงชื่อเข้าใช้สำเร็จ" หรือไม่
            Should Be Equal    ${data_text}    ลงชื่อเข้าใช้สำเร็จ
        ELSE
            # ถ้า ${status} เป็น False รอจนกว่า ${locator_no_data_message} ปรากฏภายใน 5 วินาที
            Wait Until Element Is Visible    ${locator_no_data_message}    timeout=5s
            # ตรวจสอบ ${locator_no_data_message} นั้นมีอยู่จริง
            Element Should Be Visible    ${locator_no_data_message}
            # ดึงข้อความใน ${locator_no_data_message} มาเก็บไว้ใน ${message}
            ${message}=    Get Text    ${locator_no_data_message}
            # ตรวจสอบข้อความว่าเท่ากับ "ไม่พบข้อมูลที่ต้องการค้นหา" หรือไม่
            Should Be Equal    ${message}    ไม่พบข้อมูลที่ต้องการค้นหา!
        END
    END

Select Filter Function
    [Documentation]    ตรวจสอบการคลิกเลือกฟังก์ชั่น และตรวจสอบข้อมูลในตาราง
    [Arguments]      ${text}
    Click Element    ${locator_select_function}
    Wait Until Element Is Visible               ${locator_input_filter}
    Input Text       ${locator_input_filter}    ${text}
    Click Button     ${locator_btn_search}
    
    # รอให้มีการแสดงผลอย่างใดอย่างหนึ่ง
    ${no_data_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator_no_data_message}    timeout=5s
    
    IF    ${no_data_visible}
        Element Should Be Visible          ${locator_no_data_message}
        ${message}=    Get Text            ${locator_no_data_message}
        Should Be Equal    ${message}      ไม่พบข้อมูลที่ต้องการค้นหา!
    ELSE
        ${locator_data_table_function}=    Set Variable    xpath=//div[contains(text(),'${text}')]
        Wait Until Element Is Visible      ${locator_data_table_function}    timeout=5s
        Element Should Be Visible          ${locator_data_table_function}
        ${input_text}=    Get Text         ${locator_data_table_function}
        Should Be Equal    ${input_text}    ${text}
    END

Select Filter Operation
    [Documentation]    ตรวจสอบการคลิกเลือกการดำเนินการ และตรวจสอบข้อมูลในตาราง
    [Arguments]      ${text}
    Click Element    ${locator_select_operation}
    Wait Until Element Is Visible               ${locator_input_filter}
    Input Text       ${locator_input_filter}    ${text}
    Click Button     ${locator_btn_search}
    
    # รอให้มีการแสดงผลอย่างใดอย่างหนึ่ง
    ${no_data_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator_no_data_message}    timeout=5s
    
    IF    ${no_data_visible}
        Element Should Be Visible        ${locator_no_data_message}
        ${message}=    Get Text          ${locator_no_data_message}
        Should Be Equal    ${message}    ไม่พบข้อมูลที่ต้องการค้นหา!
    ELSE
        ${locator_data_table_function}=    Set Variable    xpath=//div[contains(text(),'${text}')]
        Wait Until Element Is Visible      ${locator_data_table_function}    timeout=5s
        Element Should Be Visible          ${locator_data_table_function}
        ${input_text}=    Get Text         ${locator_data_table_function}
        Should Be Equal    ${input_text}    ${text}
    END

Select Filter
    [Documentation]    ตรวจสอบการคลิกเลือกเพิ่มตัวกรอง และตรวจสอบข้อมูลในตาราง
    [Arguments]    ${category}    ${text}
    Click Element    ${locator_btn_filter}
    Click Element    ${locator_select_filter}
    
    # แยกการทำงานตาม category
    IF    '${category}' == 'ฟังก์ชัน'    
        Select Filter Function    ${text}    
    ELSE IF    '${category}' == 'การดำเนินการ'
        Select Filter Operation    ${text}
    END
    # ปิด filter
    Wait Until Element Is Visible    ${locator_btn_cancel}    timeout=10s
    Click Element                    ${locator_btn_cancel}


Verify Number Sorting
    [Documentation]    ตรวจสอบการเรียงลำดับตัวเลขในคอลัมน์ # เมื่อคลิก sorting
    # เก็บค่าตัวเลขทั้งหมดในคอลัมน์แรก
    @{numbers}=    Get WebElements    xpath=//div[contains(@class,'company-admin-logs-activity-grid')]//div[1][not(contains(@class,'mat-sort'))]
    
    # แปลงตัวเลขเป็น list เพื่อเปรียบเทียบ
    ${original_list}=    Create List
    FOR    ${number}    IN    @{numbers}
           ${text}=    Get Text                  ${number}
           ${num}=     Convert To Integer        ${text}
           Append To List    ${original_list}    ${num}
    END
    
    # สร้าง sorted list เพื่อเปรียบเทียบ
    ${sorted_desc}=    Copy List    ${original_list}
    Sort List       ${sorted_desc}       # เรียงลำดับจากน้อยไปมาก
    Reverse List    ${sorted_desc}       # สลับลำดับให้เป็นจากมากไปน้อย
    
    # ตรวจสอบว่าเรียงจากมากไปน้อย
    Lists Should Be Equal    ${original_list}    ${sorted_desc}    
    
    # คลิกเพื่อเรียงจากน้อยไปมาก
    Click Element    ${locator_sorting_num}
    Sleep    5s
    
    # เก็บค่าตัวเลขใหม่หลังจาก sort ครั้งที่ 2
    @{numbers_asc}=    Get WebElements    xpath=//div[contains(@class,'company-admin-logs-activity-grid')]//div[1][not(contains(@class,'mat-sort'))]
    ${ascending_list}=    Create List
    FOR    ${number}    IN    @{numbers_asc}
           ${num}=     Convert To Integer         ${text}
           Append To List     ${original_list}    ${num}
    END
    
    # สร้าง sorted list แบบน้อยไปมากเพื่อเปรียบเทียบ
    ${sorted_asc}=    Copy List    ${ascending_list}
    Sort List    ${sorted_asc}
    # ตรวจสอบว่าเรียงจากน้อยไปมาก
    Lists Should Be Equal          ${ascending_list}    ${sorted_asc}

Get Login Success Logs
    [Documentation]    ตรวจสอบและดึงข้อมูลการลงชื่อเข้าใช้สำเร็จในตาราง
    Wait Until Element Is Visible    xpath://div[contains(@class, 'company-admin-logs-activity-grid')]
    
    ${elements}=    Get Webelements    xpath://div[contains(@class, 'company-admin-logs-activity-grid')]
    FOR    ${element}    IN    @{elements}
        ${operation}=    Get Text    xpath=.//div[5]    # ดึงข้อมูลในคอลัมน์ "ลงชื่อเข้าใช้สำเร็จ"
        ${date}=    Get Text    xpath=.//div[6]    # ดึงข้อมูลวันที่ในคอลัมน์ "วันที่ดำเนินการ"
        Run Keyword If    '${operation}' == 'ลงชื่อเข้าใช้สำเร็จ'    Log    Operation: ${operation}, Date: ${date}
    END
    Close Browser



*** Test Cases ***
TC07-001 Search Activity Logs - Fail
    [Documentation]    ตรวจสอบการค้นหา Activity Log และการแจ้งเตือนไม่พบข้อมูลในตาราง
    Open Log application
    Search Select Date    วันที่เริ่ม    2020    SEP    14 
    Search Select Date    วันที่จบ    2020    SEP    14
    Close Browser

TC07-002 Search Activity Logs - Pass
    [Documentation]    ตรวจสอบการค้นหา Activity Log และตรวจสอบข้อมูลในตาราง
    Open Log application
    Search Select Date    วันที่เริ่ม    2024    SEP    14 
    Search Select Date    วันที่จบ    2024    SEP    17
    Close Browser

TC07-003 Search Activity Logs - Fail
    [Documentation]    ตรวจสอบการค้นหาประเภทตัวกรองที่อนุญาต และการแจ้งเตือนไม่พบข้อมูลในตาราง
    Open Log application
    Select Filter    ฟังก์ชัน         TT
    Select Filter    การดำเนินการ    EE
    

TC07-004 Search Filter - Pass
    [Documentation]    ตรวจสอบการค้นหาประเภทตัวกรองที่อนุญาต และตรวจข้อมูลในตาราง
    Select Filter    ฟังก์ชัน         sign-in
    Select Filter    การดำเนินการ    sign-in
    Close Browser

TC07-005 Sorting Number Column
    [Documentation]    ทดสอบการเรียงลำดับตัวเลขในคอลัมน์ #
    Open Log application
    Search Select Date    วันที่เริ่ม    2024    SEP    15
    Search Select Date    วันที่จบ    2024    SEP    16
    Verify Number Sorting
    Close Browser
    
TC07-007 Sorting operation Column
    [Documentation]    ทดสอบการเรียงลำดับตัวอักษรในคอลัมน์ operation
    Open Log application
    Search Select Date    วันที่เริ่ม    2024    SEP    15
    Search Select Date    วันที่จบ    2024    SEP    16
    Get Login Success Logs


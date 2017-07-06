*** Settings ***
Force Tags      pybot   jybot
Resource        resources/sftp.robot
Suite Setup     Login As Valid User
Suite Teardown  Close All Connections
Library         OperatingSystem  WITH NAME  OS
Library         Collections

*** Test Cases ***
Put Directory To Existing Remote Path
    [Setup]  SSH.Directory Should Not Exist  textfiles
    Create File With Colon Char In Its Name
    Put Directory  ${LOCAL TEXTFILES}  .
    Remote Directory Should Exist With Content  ./textfiles
    Check And Remove Local Added Directory   ./textfiles
    [Teardown]  Execute Command  rm -rf ./textfiles

Put Directory To Non-Existing Remote Path
    [Setup]  SSH.Directory Should Not Exist  another_dir_name
    Create File With Colon Char In Its Name
    Put Directory  ${LOCAL TEXTFILES}  another_dir_name
    Remote Directory Should Exist With Content  another_dir_name
    Check And Remove Local Added Directory   another_dir_name
    [Teardown]  Execute Command  rm -rf another_dir_name

Put Directory Including Subdirectories To Existing Remote Path
    Create File With Colon Char In Its Name
    Put Directory  ${LOCAL TEXTFILES}  .  recursive=True
    Remote Directory Should Exist With Subdirectories  ./textfiles
    Check And Remove Local Added Directory  ./textfiles
    [Teardown]  Execute Command  rm -rf ./textfiles

Put Directory Including Subdirectories To Non-Existing Remote Path
    [Setup]  SSH.Directory Should Not Exist  another/dir/path
    Create File With Colon Char In Its Name
    Put Directory  ${LOCAL TEXTFILES}  another/dir/path  recursive=True
    Remote Directory Should Exist With Subdirectories  another/dir/path
    Check And Remove Local Added Directory   another/dir/path
    [Teardown]  Execute Command  rm -rf another

Put Directory Including Empty Subdirectories
    [Setup]  OS.Create Directory  ${LOCAL TEXTFILES}${/}empty
    Create File With Colon Char In Its Name
    Put Directory  ${LOCAL TEXTFILES}  .  recursive=True
    SSH.Directory Should Exist  textfiles/empty
    Remote Directory Should Exist With Subdirectories  textfiles
    Check And Remove Local Added Directory   ./textfiles
    [Teardown]  Remove Local Empty Directory And Remote Files

Put Directory Using Relative Source
    [Setup]  SSH.Directory Should Not Exist  ${REMOTE TEST ROOT}
    Create File With Colon Char In Its Name
    Put Directory  ${CURDIR}${/}testdata${/}textfiles  ${REMOTE TEST ROOT}
    Remote Directory Should Exist With Content  ${REMOTE TEST ROOT}
    Check And Remove Local Added Directory  ${REMOTE TEST ROOT}
    [Teardown]  Execute Command  rm -rf ${REMOTE TEST ROOT}

Put Directory Should Fail When Source Does Not Exists
    Run Keyword And Expect Error  There was no source path matching 'non-existing'.
    ...                           Put Directory  non-existing

*** Keywords ***
Remove Local Empty Directory And Remote Files
    OS.Remove Directory  ${LOCAL TEXTFILES}${/}empty
    Execute Command  rm -rf ./textfiles

Remote Directory Should Exist With Content
    [Arguments]  ${destination}
    SSH.File Should Exist  ${destination}/${TEST FILE NAME}
    SSH.File Should Exist  ${destination}/${FILE WITH NEWLINES NAME}
    SSH.File Should Exist  ${destination}/${FILE WITH SPECIAL CHARS NAME}
    SSH.File Should Not Exist  ${destination}/${FILE WITH NON-ASCII NAME}
    SSH.Directory Should Not Exist  ${destination}/${SUBDIRECTORY NAME}

Remote Directory Should Exist With Subdirectories
    [Arguments]  ${destination}
    SSH.File Should Exist  ${destination}/${TEST FILE NAME}
    SSH.File Should Exist  ${destination}/${FILE WITH NEWLINES NAME}
    SSH.File Should Exist  ${destination}/${FILE WITH SPECIAL CHARS NAME}
    SSH.File Should Not Exist  ${destination}/${FILE WITH NON-ASCII NAME}
    SSH.File Should Exist  ${destination}/${SUBDIRECTORY NAME}/${FILE WITH NON-ASCII NAME}

Create File With Colon Char In Its Name
    [Tags]  linux
    SSH.File Should Not Exist   ${COLON CHAR FILE}
    OS.Create File  ${COLON CHAR FILE}

Check And Remove Local Added Directory
    [Tags]  linux
    [Arguments]  ${destination}
    ${files_list} =  SSH.List Files In Directory  ${destination}
    List should contain value  ${files_list}  ${COLON CHAR FILE_NAME}
    [Teardown]  OS.Remove File  ${COLON CHAR FILE}

@echo off
:ReStart
cd %~dp0
echo /*************** Version 5.0 ---Copy Right Reserved *************/
echo  目录选择
echo     1: EMB5216_HL_MP
echo     2: EMB5216_HL
echo     3: EMB5216_SSW
echo      0：手动目录输入
set /p dir=

if %dir%==1 (cd ..\EMB5216_HL_MP
goto :function)

if %dir%==2 (cd ..\EMB5216_HL
goto :function)

if %dir%==3 (cd ..\EMB5216_SSW
goto :function)

if not %dir%==0 (echo 无效输入!!
goto :ReStart)

echo 请输入目录：
set /p user_dir=
cd ..\%user_dir%
goto :function

echo 无效输入!!
goto :file_end


:function
echo  当前操作目录%cd%
echo  请选择您需要进行的操作：
echo    1: 查询打指定标签的文件;
echo    2: 删除指定的标签;
echo    3: 将打指定标签的文件再打上另一个标签;
echo    4: 将私有分支打U标的文件升级到指定主分支，并打上指定的B标;
echo    5: 查询同时打了两个标签的文件，并显示第一个标签所在节点;
echo    6: 创建一个新的U标;
echo    7: 给指定分支最新节点打标(已有的标签将移到最新节点);
echo    8: 代码规范性修改(暂不支持‘*'号单边没有空格的情况);
echo    9: 给Check Out的文件打标;
echo    10:列出Check Out的文件;
echo    11:取消所有Checkout的文件：Undo Checkout;
echo    12:创建一个新的私有分支;
echo    13:给指定文件打标;
echo    14:拉分支;
echo    15:标签锁定与解锁;
echo    16:将所有Checkout的文件Checkin；
echo    20:定制功能1: TDCUP MAC四期文件Checkout后打B标；
echo    0: 返回目录选择;
echo  注意：其他输入均无效，任意时刻输入"BACK"将返回功能选择
set /p ser_Type=

if %ser_Type%==1 goto :Apply_Label
if %ser_Type%==2 goto :Del_Label
if %ser_Type%==3 goto :Add_Label
if %ser_Type%==4 goto :U2B
if %ser_Type%==5 goto :File_Label
if %ser_Type%==6 goto :Create_Label
if %ser_Type%==7 goto :Label_Latest
if %ser_Type%==8 goto :Code_Regular
if %ser_Type%==9 goto :LCO_file
if %ser_Type%==10 goto :LSC0
if %ser_Type%==11 goto :UNCO
if %ser_Type%==12 goto :Create_Branch
if %ser_Type%==13 goto :SF_Label
if %ser_Type%==14 goto :MK_Branch
if %ser_Type%==15 goto :LB_LOCK_UNLOCK
if %ser_Type%==16 goto :CHECK_IN
if %ser_Type%==20 goto :APPLY_TDCUP_V4_B_LABEL
if %ser_Type%==0 goto :ReStart
if %ser_Type%==BACK goto :function
echo  ERROR: 输入有误，请重新输入指定功能对应的数字!
goto :function

:Apply_Label
echo  您选择了“1”：查询打指定标签的文件；
echo  请输入您要查询的标签:
set /p S_Label=
if %S_Label%==BACK goto :function
%~dp0\src\execute_file.pl 00 00 %S_Label%
type %~dp0\src\macroNB_update_tmp.txt
%~dp0\src\macroNB_update_tmp.txt
goto :ReStart

:Del_Label
echo  您选择了“2”：删除指定的标签；
echo  请输入您要删除的标签:
set /p Del_Label=
if %Del_Label%==BACK goto :function
echo  请输入"Y"确认
set /p Falg=
if %Falg%==Y goto :DEL_LB_Y
goto :function
:DEL_LB_Y
%~dp0\src\execute_file.pl 22 00 %Del_Label%
goto :ReStart

:Add_Label
echo  您选择了“3”：将打指定标签的文件再打上另一个标签；
echo  请输入已经存在的标签:
set /p old_Label=
if %old_Label%==BACK goto :function
echo  请输入您要在已经存在的标签位置打的新标签:
set /p new_Label=
if %new_Label%==BACK goto :function
echo  请输入"Y"确认
set /p Falg=
if %Falg%==Y goto :AD_LB_Y
goto :function
:AD_LB_Y
%~dp0\src\execute_file.pl 33 00 %old_Label% %new_Label%

type %~dp0\src\macroNB_dif.txt
goto :ReStart

:U2B
echo  您选择了“4”：将私有分支打U标的文件升级到指定主分支，并打上指定的B标;
echo  使用提示:
echo     1. 完成后U标将被删除；强烈建议先使用功能‘3’在私有分支上打两个标签；
echo     2. 4.0版本开始不再自动CheckIn，请待全部归并完后利用CC本身的工具CheckIn；
echo  请输入您在私有分支修改完毕后打上的U标:
set /p U_Label=
if %U_Label%==BACK goto :function
echo  请输入本次升级主分支:
%~dp0\src\show_branch_name.pl
set /p Brath=
if %Brath%==BACK goto :function
echo  请输入本次升级主分支上使用的B标(不打标请输入大写"N"):
set /p B_Label=
echo  您将进行U标到B标的升级，请确认：
echo         1. 本地View取标规则中U标在最前面(建议Updata View)! 
echo         2. U标、B标输入正确;
echo         3. 要升级的主分支正确;
echo  请输入"Y"确认
set /p Falg=
if %Falg%==Y goto :U2B_Y
goto :function
:U2B_Y
%~dp0\src\newCodeMerge.pl 44 %Brath% %U_Label% %B_Label%
goto :ReStart


:File_Label
echo  您选择了“5”：查询同时打了两个标签的文件，并显示第一个标签所在节点；
echo  请输入第一个标签:
set /p main_Label=
if %main_Label%==BACK goto :function
echo  请输入第二个标签:
set /p pre_Label=
if %pre_Label%==BACK goto :function
%~dp0\src\execute_file.pl 55 %main_Label% %pre_Label% 00
type %~dp0\src\macroNB_update_tmp.txt
%~dp0\src\macroNB_update_tmp.txt 
goto :ReStart

:Create_Label
echo  您选择了“6”：创建一个新的U标；
echo  请输入您要新建的U标(请用‘U_’开始):
set /p N_Label=
if %N_Label%==BACK goto :function
echo  请输入"Y"确认(大写)
set /p CU_Falg=
if %CU_Falg%==Y goto :CU_Y
echo   操作取消
goto :function
:CU_Y
%~dp0\src\execute_file.pl 66 00 %N_Label%
goto :ReStart

:Label_Latest
echo  您选择了“7”：给指定分支最新节点打标(已有的标签将移到最新节点);
echo  请输入您要打标的分支名：
set /p LB_Branch=
if %LB_Branch%==BACK goto :function
echo  请输入您在最新分支上要打的标签：
set /p Latest_Lable=
if %Latest_Lable%==BACK goto :function
echo  请输入"Y"确认(大写)
set /p LBB_Falg=
if %LBB_Falg%==Y goto :LBB_Y
echo   操作取消
goto :function
:LBB_Y
%~dp0\src\execute_file.pl 77 %LB_Branch% %Latest_Lable%
goto :ReStart

:Code_Regular
echo  您选择了“8”：代码规范性修改
echo  请选择进行规范性修改模式:
echo      1: 对View下所有.c\.h文件(非‘只读’文件)规范性修改(空格问题); 
echo      2: 对输入的指定文件(非‘只读’文件)进行规范性修改(空格问题);
echo      3: 对View下所有.c\.h文件(含‘只读’文件)规范性检查(基于CheckList); 
echo      4: 对输入的指定文件(含‘只读’文件)进行规范性检查(基于CheckList);
echo      5: 对View下所有.c\.h文件(含‘只读’文件)规范性检查(扩展版); 
echo      6: 对输入的指定文件(含‘只读’文件)进行规范性检查(扩展版);
echo      7: 对View下所有.c\.h文件(含‘只读’文件)进行规范性修改(基于CheckList，空格问题);
echo      8: 对输入的指定文件(含‘只读’文件)进行规范性修改(基于CheckList，空格问题);
set /p CR_Mode=
if %CR_Mode%==1 goto :CR_Mode1
if %CR_Mode%==2 goto :CR_Mode2
if %CR_Mode%==3 goto :CR_Mode3
if %CR_Mode%==4 goto :CR_Mode4
if %CR_Mode%==5 goto :CR_Mode5
if %CR_Mode%==6 goto :CR_Mode6
if %CR_Mode%==7 goto :CR_Mode7
if %CR_Mode%==8 goto :CR_Mode8
if %CR_Mode%==BACK goto :function
echo  错误的输入，只能输入‘1’、‘2’、‘3’或‘4’!
goto :Code_Regular
:CR_Mode1
%~dp0\src\dir.pl "CR_Mode1" 00 11
goto :ReStart

:CR_Mode2
echo  请输入您要进行规范性修改的文件名(含扩展名):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\dir.pl "CR_Mode2" %CR_fileName% 11
goto :ReStart

:CR_Mode3
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode3" 00 00
goto :ReStart

:CR_Mode4
echo  请输入您要进行规范性修改的文件名(含扩展名):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode4" %CR_fileName% 00
goto :ReStart

:CR_Mode5
%~dp0\src\dir.pl "CR_Mode3" 00 00
goto :ReStart

:CR_Mode6
echo  请输入您要进行规范性修改的文件名(含扩展名):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\dir.pl "CR_Mode4" %CR_fileName% 00
goto :ReStart

:CR_Mode7
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode1" 00 11
goto :ReStart

:CR_Mode8
echo  请输入您要进行规范性修改的文件名(含扩展名):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode2" %CR_fileName% 11
goto :ReStart

:LCO_file
echo  您选择了“9”：给Check Out的文件打标；
echo  请输入将给Check Out文件打上的标签：
set /p CO_Label=
if %CO_Label%==BACK goto :function
%~dp0\src\OpCheckoutElmt.pl "CO_APPLY_LABEL" 00 %CO_Label%
goto :ReStart

:LSC0
echo  您选择了“10”：列出Check Out的文件；
echo     1: Checkout文件；
echo     2: 可读写文件；
set /p LSCO_Mode_Flag=
if %LSCO_Mode_Flag%==BACK goto :function
if %LSCO_Mode_Flag%==1 goto :LSCO_Mode1
if %LSCO_Mode_Flag%==2 goto :LSCO_Mode2
if %LSCO_Mode_Flag%==3 goto :LSCO_Mode3
echo  输入错误!
goto :function
:LSCO_Mode1
echo  Checkout文件:
%~dp0\src\OpCheckoutElmt.pl "LS_CO" 00 00
goto :ReStart
:LSCO_Mode2
echo 可读写文件:
%~dp0\src\dir.pl "LSCO_Mode2" 00 00
goto :ReStart
:LSCO_Mode3
echo  Checkout文件——全路径名模式；
%~dp0\src\OpCheckoutElmt.pl "LS_CO" 00 00
goto :ReStart

:UNCO
echo  您选择了“11”：取消所有Checkout的文件：Undo Checkout；
echo    输入 Y 确认!! （注意：不可恢复）
set /p UNCO_Flag=
if %UNCO_Flag%==Y goto :UN_CO_Y
echo  Undo Checkout 操作取消
goto :function
:UN_CO_Y
%~dp0\src\OpCheckoutElmt.pl "UN_CO" 00 00
goto :ReStart

:CHECK_IN
echo  您选择了“16”：将所有Checkout的文件Checkin；
echo    请输入Checkin节点需要添加的注释:
set /p CI_Comment=
if %CI_Comment%==BACK goto :function
echo    输入 Y 确认!! （注意：不可恢复）
set /p CI_Flag=
if %CI_Flag%==Y goto :CHECK_IN_Y
echo  checkin 操作取消
goto :function
:CHECK_IN_Y
%~dp0\src\OpCheckoutElmt.pl "CHECK_IN" %CI_Comment% 00
goto :ReStart

:Create_Branch
echo  您选择了“12”：创建一个新的私有分支；
echo  请输入您要新建的私有分支(请用‘U_’开始):
set /p N_Branch=
if %N_Branch%==BACK goto :function
echo  请输入"Y"确认(大写)
set /p CB_Falg=
if %CB_Falg%==Y goto :CB_Y
echo 操作已取消
goto :function
:CB_Y
%~dp0\src\execute_file.pl 88 00 %N_Branch%
goto :ReStart

:SF_Label
echo  您选择了“13”：给指定文件打标；
echo  请输入指定的文件:
set /p Sep_File=
if %Sep_File%==BACK goto :function
echo  请输入需要打上的标签:
set /p Sep_Label=
if %Sep_Label%==BACK goto :function
echo  请输入"Y"确认(大写)
set /p SF_L_Falg=
if %SF_L_Falg%==Y goto :SF_L_Y
echo  操作取消
goto :function
:SF_L_Y
%~dp0\src\dir.pl "SpeF_Label" %Sep_File% %Sep_Label%
goto :ReStart


:MK_Branch
echo  您选择了“14”：拉分支；
echo      输入拉分支基于的标签名：
set /p mk_br_label=
if %mk_br_label%==BACK goto :function
echo      输入要拉出的分支名：
set /p new_branch=
if %new_branch%==BACK goto :function
echo      输入文件名（含扩展名, 如对所有打标文件拉分支输入ALLALL）：
set /p sp_file_name=
if %sp_file_name%==BACK goto :function
echo      输入 Y 确认!! （注意：不可恢复）
set /p MKBR_Flag=
if %MKBR_Flag%==Y goto :MK_BR_Y
echo      操作取消
goto :function
:MK_BR_Y
%~dp0\src\mkbranch.pl 11 %sp_file_name% %mk_br_label% %new_branch%
goto :ReStart


:LB_LOCK_UNLOCK
echo  您选择了“15”：标签锁定与解锁;
echo     1: 标签锁定;
echo     2: 标签解锁;
set /p LBLUL_Mode_Flag=
if %LBLUL_Mode_Flag%==1 goto :LBLUL_Mode1
if %LBLUL_Mode_Flag%==2 goto :LBLUL_Mode2
goto :function
:LBLUL_Mode1
echo      输入需要锁定的标签名：
set /p lock_label_name=
if %lock_label_name%==BACK goto :function
cleartool lock lbtype:%lock_label_name%
goto :ReStart
:LBLUL_Mode2
echo      输入需要解锁的标签名：
set /p unlock_label_name=
if %unlock_label_name%==BACK goto :function
cleartool unlock lbtype:%unlock_label_name%
goto :ReStart


echo 删除标签
echo rmtype -force -rmall lbtype:U_temp_20110323

:APPLY_TDCUP_V4_B_LABEL
echo  您选择了“20”：定制功能1---TDCUP MAC四期文件Checkout后打B标；
echo     请输入PLP标签：
set /p ATVBL_PLP_Label=
if %ATVBL_PLP_Label%==BACK goto :function
echo     请输入BCPE1标签：
set /p ATVBL_BCPE1_Label=
if %ATVBL_BCPE1_Label%==BACK goto :function
echo      输入 Y 确认!! （注意：不可恢复）
set /p AP_TDCUP_V4_B_LABEL_Flag=
if %AP_TDCUP_V4_B_LABEL_Flag%==Y goto :AP_TDCUP_V4_B_LABEL_Y
echo      操作取消
goto :function
:AP_TDCUP_V4_B_LABEL_Y
%~dp0\src\OpCheckoutElmt.pl "APPLY_TDCUP_V4_B_LABEL" %ATVBL_PLP_Label% %ATVBL_BCPE1_Label%
goto :ReStart
:file_end
echo end
pause

@echo off
:ReStart
cd %~dp0
echo /*************** Version 5.0 ---Copy Right Reserved *************/
echo  Ŀ¼ѡ��
echo     1: EMB5216_HL_MP
echo     2: EMB5216_HL
echo     3: EMB5216_SSW
echo      0���ֶ�Ŀ¼����
set /p dir=

if %dir%==1 (cd ..\EMB5216_HL_MP
goto :function)

if %dir%==2 (cd ..\EMB5216_HL
goto :function)

if %dir%==3 (cd ..\EMB5216_SSW
goto :function)

if not %dir%==0 (echo ��Ч����!!
goto :ReStart)

echo ������Ŀ¼��
set /p user_dir=
cd ..\%user_dir%
goto :function

echo ��Ч����!!
goto :file_end


:function
echo  ��ǰ����Ŀ¼%cd%
echo  ��ѡ������Ҫ���еĲ�����
echo    1: ��ѯ��ָ����ǩ���ļ�;
echo    2: ɾ��ָ���ı�ǩ;
echo    3: ����ָ����ǩ���ļ��ٴ�����һ����ǩ;
echo    4: ��˽�з�֧��U����ļ�������ָ������֧��������ָ����B��;
echo    5: ��ѯͬʱ����������ǩ���ļ�������ʾ��һ����ǩ���ڽڵ�;
echo    6: ����һ���µ�U��;
echo    7: ��ָ����֧���½ڵ���(���еı�ǩ���Ƶ����½ڵ�);
echo    8: ����淶���޸�(�ݲ�֧�֡�*'�ŵ���û�пո�����);
echo    9: ��Check Out���ļ����;
echo    10:�г�Check Out���ļ�;
echo    11:ȡ������Checkout���ļ���Undo Checkout;
echo    12:����һ���µ�˽�з�֧;
echo    13:��ָ���ļ����;
echo    14:����֧;
echo    15:��ǩ���������;
echo    16:������Checkout���ļ�Checkin��
echo    20:���ƹ���1: TDCUP MAC�����ļ�Checkout���B�ꣻ
echo    0: ����Ŀ¼ѡ��;
echo  ע�⣺�����������Ч������ʱ������"BACK"�����ع���ѡ��
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
echo  ERROR: ������������������ָ�����ܶ�Ӧ������!
goto :function

:Apply_Label
echo  ��ѡ���ˡ�1������ѯ��ָ����ǩ���ļ���
echo  ��������Ҫ��ѯ�ı�ǩ:
set /p S_Label=
if %S_Label%==BACK goto :function
%~dp0\src\execute_file.pl 00 00 %S_Label%
type %~dp0\src\macroNB_update_tmp.txt
%~dp0\src\macroNB_update_tmp.txt
goto :ReStart

:Del_Label
echo  ��ѡ���ˡ�2����ɾ��ָ���ı�ǩ��
echo  ��������Ҫɾ���ı�ǩ:
set /p Del_Label=
if %Del_Label%==BACK goto :function
echo  ������"Y"ȷ��
set /p Falg=
if %Falg%==Y goto :DEL_LB_Y
goto :function
:DEL_LB_Y
%~dp0\src\execute_file.pl 22 00 %Del_Label%
goto :ReStart

:Add_Label
echo  ��ѡ���ˡ�3��������ָ����ǩ���ļ��ٴ�����һ����ǩ��
echo  �������Ѿ����ڵı�ǩ:
set /p old_Label=
if %old_Label%==BACK goto :function
echo  ��������Ҫ���Ѿ����ڵı�ǩλ�ô���±�ǩ:
set /p new_Label=
if %new_Label%==BACK goto :function
echo  ������"Y"ȷ��
set /p Falg=
if %Falg%==Y goto :AD_LB_Y
goto :function
:AD_LB_Y
%~dp0\src\execute_file.pl 33 00 %old_Label% %new_Label%

type %~dp0\src\macroNB_dif.txt
goto :ReStart

:U2B
echo  ��ѡ���ˡ�4������˽�з�֧��U����ļ�������ָ������֧��������ָ����B��;
echo  ʹ����ʾ:
echo     1. ��ɺ�U�꽫��ɾ����ǿ�ҽ�����ʹ�ù��ܡ�3����˽�з�֧�ϴ�������ǩ��
echo     2. 4.0�汾��ʼ�����Զ�CheckIn�����ȫ���鲢�������CC����Ĺ���CheckIn��
echo  ����������˽�з�֧�޸���Ϻ���ϵ�U��:
set /p U_Label=
if %U_Label%==BACK goto :function
echo  �����뱾����������֧:
%~dp0\src\show_branch_name.pl
set /p Brath=
if %Brath%==BACK goto :function
echo  �����뱾����������֧��ʹ�õ�B��(������������д"N"):
set /p B_Label=
echo  ��������U�굽B�����������ȷ�ϣ�
echo         1. ����Viewȡ�������U������ǰ��(����Updata View)! 
echo         2. U�ꡢB��������ȷ;
echo         3. Ҫ����������֧��ȷ;
echo  ������"Y"ȷ��
set /p Falg=
if %Falg%==Y goto :U2B_Y
goto :function
:U2B_Y
%~dp0\src\newCodeMerge.pl 44 %Brath% %U_Label% %B_Label%
goto :ReStart


:File_Label
echo  ��ѡ���ˡ�5������ѯͬʱ����������ǩ���ļ�������ʾ��һ����ǩ���ڽڵ㣻
echo  �������һ����ǩ:
set /p main_Label=
if %main_Label%==BACK goto :function
echo  ������ڶ�����ǩ:
set /p pre_Label=
if %pre_Label%==BACK goto :function
%~dp0\src\execute_file.pl 55 %main_Label% %pre_Label% 00
type %~dp0\src\macroNB_update_tmp.txt
%~dp0\src\macroNB_update_tmp.txt 
goto :ReStart

:Create_Label
echo  ��ѡ���ˡ�6��������һ���µ�U�ꣻ
echo  ��������Ҫ�½���U��(���á�U_����ʼ):
set /p N_Label=
if %N_Label%==BACK goto :function
echo  ������"Y"ȷ��(��д)
set /p CU_Falg=
if %CU_Falg%==Y goto :CU_Y
echo   ����ȡ��
goto :function
:CU_Y
%~dp0\src\execute_file.pl 66 00 %N_Label%
goto :ReStart

:Label_Latest
echo  ��ѡ���ˡ�7������ָ����֧���½ڵ���(���еı�ǩ���Ƶ����½ڵ�);
echo  ��������Ҫ���ķ�֧����
set /p LB_Branch=
if %LB_Branch%==BACK goto :function
echo  �������������·�֧��Ҫ��ı�ǩ��
set /p Latest_Lable=
if %Latest_Lable%==BACK goto :function
echo  ������"Y"ȷ��(��д)
set /p LBB_Falg=
if %LBB_Falg%==Y goto :LBB_Y
echo   ����ȡ��
goto :function
:LBB_Y
%~dp0\src\execute_file.pl 77 %LB_Branch% %Latest_Lable%
goto :ReStart

:Code_Regular
echo  ��ѡ���ˡ�8��������淶���޸�
echo  ��ѡ����й淶���޸�ģʽ:
echo      1: ��View������.c\.h�ļ�(�ǡ�ֻ�����ļ�)�淶���޸�(�ո�����); 
echo      2: �������ָ���ļ�(�ǡ�ֻ�����ļ�)���й淶���޸�(�ո�����);
echo      3: ��View������.c\.h�ļ�(����ֻ�����ļ�)�淶�Լ��(����CheckList); 
echo      4: �������ָ���ļ�(����ֻ�����ļ�)���й淶�Լ��(����CheckList);
echo      5: ��View������.c\.h�ļ�(����ֻ�����ļ�)�淶�Լ��(��չ��); 
echo      6: �������ָ���ļ�(����ֻ�����ļ�)���й淶�Լ��(��չ��);
echo      7: ��View������.c\.h�ļ�(����ֻ�����ļ�)���й淶���޸�(����CheckList���ո�����);
echo      8: �������ָ���ļ�(����ֻ�����ļ�)���й淶���޸�(����CheckList���ո�����);
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
echo  ��������룬ֻ�����롮1������2������3����4��!
goto :Code_Regular
:CR_Mode1
%~dp0\src\dir.pl "CR_Mode1" 00 11
goto :ReStart

:CR_Mode2
echo  ��������Ҫ���й淶���޸ĵ��ļ���(����չ��):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\dir.pl "CR_Mode2" %CR_fileName% 11
goto :ReStart

:CR_Mode3
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode3" 00 00
goto :ReStart

:CR_Mode4
echo  ��������Ҫ���й淶���޸ĵ��ļ���(����չ��):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode4" %CR_fileName% 00
goto :ReStart

:CR_Mode5
%~dp0\src\dir.pl "CR_Mode3" 00 00
goto :ReStart

:CR_Mode6
echo  ��������Ҫ���й淶���޸ĵ��ļ���(����չ��):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\dir.pl "CR_Mode4" %CR_fileName% 00
goto :ReStart

:CR_Mode7
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode1" 00 11
goto :ReStart

:CR_Mode8
echo  ��������Ҫ���й淶���޸ĵ��ļ���(����չ��):
set /p CR_fileName=
if %CR_fileName%==BACK goto :function
%~dp0\src\CodeRugCheckSrc.pl "CR_Mode2" %CR_fileName% 11
goto :ReStart

:LCO_file
echo  ��ѡ���ˡ�9������Check Out���ļ���ꣻ
echo  �����뽫��Check Out�ļ����ϵı�ǩ��
set /p CO_Label=
if %CO_Label%==BACK goto :function
%~dp0\src\OpCheckoutElmt.pl "CO_APPLY_LABEL" 00 %CO_Label%
goto :ReStart

:LSC0
echo  ��ѡ���ˡ�10�����г�Check Out���ļ���
echo     1: Checkout�ļ���
echo     2: �ɶ�д�ļ���
set /p LSCO_Mode_Flag=
if %LSCO_Mode_Flag%==BACK goto :function
if %LSCO_Mode_Flag%==1 goto :LSCO_Mode1
if %LSCO_Mode_Flag%==2 goto :LSCO_Mode2
if %LSCO_Mode_Flag%==3 goto :LSCO_Mode3
echo  �������!
goto :function
:LSCO_Mode1
echo  Checkout�ļ�:
%~dp0\src\OpCheckoutElmt.pl "LS_CO" 00 00
goto :ReStart
:LSCO_Mode2
echo �ɶ�д�ļ�:
%~dp0\src\dir.pl "LSCO_Mode2" 00 00
goto :ReStart
:LSCO_Mode3
echo  Checkout�ļ�����ȫ·����ģʽ��
%~dp0\src\OpCheckoutElmt.pl "LS_CO" 00 00
goto :ReStart

:UNCO
echo  ��ѡ���ˡ�11����ȡ������Checkout���ļ���Undo Checkout��
echo    ���� Y ȷ��!! ��ע�⣺���ɻָ���
set /p UNCO_Flag=
if %UNCO_Flag%==Y goto :UN_CO_Y
echo  Undo Checkout ����ȡ��
goto :function
:UN_CO_Y
%~dp0\src\OpCheckoutElmt.pl "UN_CO" 00 00
goto :ReStart

:CHECK_IN
echo  ��ѡ���ˡ�16����������Checkout���ļ�Checkin��
echo    ������Checkin�ڵ���Ҫ��ӵ�ע��:
set /p CI_Comment=
if %CI_Comment%==BACK goto :function
echo    ���� Y ȷ��!! ��ע�⣺���ɻָ���
set /p CI_Flag=
if %CI_Flag%==Y goto :CHECK_IN_Y
echo  checkin ����ȡ��
goto :function
:CHECK_IN_Y
%~dp0\src\OpCheckoutElmt.pl "CHECK_IN" %CI_Comment% 00
goto :ReStart

:Create_Branch
echo  ��ѡ���ˡ�12��������һ���µ�˽�з�֧��
echo  ��������Ҫ�½���˽�з�֧(���á�U_����ʼ):
set /p N_Branch=
if %N_Branch%==BACK goto :function
echo  ������"Y"ȷ��(��д)
set /p CB_Falg=
if %CB_Falg%==Y goto :CB_Y
echo ������ȡ��
goto :function
:CB_Y
%~dp0\src\execute_file.pl 88 00 %N_Branch%
goto :ReStart

:SF_Label
echo  ��ѡ���ˡ�13������ָ���ļ���ꣻ
echo  ������ָ�����ļ�:
set /p Sep_File=
if %Sep_File%==BACK goto :function
echo  ��������Ҫ���ϵı�ǩ:
set /p Sep_Label=
if %Sep_Label%==BACK goto :function
echo  ������"Y"ȷ��(��д)
set /p SF_L_Falg=
if %SF_L_Falg%==Y goto :SF_L_Y
echo  ����ȡ��
goto :function
:SF_L_Y
%~dp0\src\dir.pl "SpeF_Label" %Sep_File% %Sep_Label%
goto :ReStart


:MK_Branch
echo  ��ѡ���ˡ�14��������֧��
echo      ��������֧���ڵı�ǩ����
set /p mk_br_label=
if %mk_br_label%==BACK goto :function
echo      ����Ҫ�����ķ�֧����
set /p new_branch=
if %new_branch%==BACK goto :function
echo      �����ļ���������չ��, ������д���ļ�����֧����ALLALL����
set /p sp_file_name=
if %sp_file_name%==BACK goto :function
echo      ���� Y ȷ��!! ��ע�⣺���ɻָ���
set /p MKBR_Flag=
if %MKBR_Flag%==Y goto :MK_BR_Y
echo      ����ȡ��
goto :function
:MK_BR_Y
%~dp0\src\mkbranch.pl 11 %sp_file_name% %mk_br_label% %new_branch%
goto :ReStart


:LB_LOCK_UNLOCK
echo  ��ѡ���ˡ�15������ǩ���������;
echo     1: ��ǩ����;
echo     2: ��ǩ����;
set /p LBLUL_Mode_Flag=
if %LBLUL_Mode_Flag%==1 goto :LBLUL_Mode1
if %LBLUL_Mode_Flag%==2 goto :LBLUL_Mode2
goto :function
:LBLUL_Mode1
echo      ������Ҫ�����ı�ǩ����
set /p lock_label_name=
if %lock_label_name%==BACK goto :function
cleartool lock lbtype:%lock_label_name%
goto :ReStart
:LBLUL_Mode2
echo      ������Ҫ�����ı�ǩ����
set /p unlock_label_name=
if %unlock_label_name%==BACK goto :function
cleartool unlock lbtype:%unlock_label_name%
goto :ReStart


echo ɾ����ǩ
echo rmtype -force -rmall lbtype:U_temp_20110323

:APPLY_TDCUP_V4_B_LABEL
echo  ��ѡ���ˡ�20�������ƹ���1---TDCUP MAC�����ļ�Checkout���B�ꣻ
echo     ������PLP��ǩ��
set /p ATVBL_PLP_Label=
if %ATVBL_PLP_Label%==BACK goto :function
echo     ������BCPE1��ǩ��
set /p ATVBL_BCPE1_Label=
if %ATVBL_BCPE1_Label%==BACK goto :function
echo      ���� Y ȷ��!! ��ע�⣺���ɻָ���
set /p AP_TDCUP_V4_B_LABEL_Flag=
if %AP_TDCUP_V4_B_LABEL_Flag%==Y goto :AP_TDCUP_V4_B_LABEL_Y
echo      ����ȡ��
goto :function
:AP_TDCUP_V4_B_LABEL_Y
%~dp0\src\OpCheckoutElmt.pl "APPLY_TDCUP_V4_B_LABEL" %ATVBL_PLP_Label% %ATVBL_BCPE1_Label%
goto :ReStart
:file_end
echo end
pause

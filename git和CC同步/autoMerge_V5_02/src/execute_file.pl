##############################################################################
# FILE:     update.pl
# AUTHOR:   bujianhui, L2FP Group, SW2 Sec.
# PURPOSE:  merge files with private label to dev branch and
#           apply public label to the latter.
# ARGV[0]:  11 OR others
# ARGV[1]:  private label, looks like U_XXX_YYY_NNN
# ARGV[2]:  public  label, looks like B_TDB144A_V3.0.00_XXX_YYY_NNN
# COMMENTS: 
# HISTORY:
# 2010/06/11  bujianhui  ɾ��U2B���ɵ���ʱ�ļ�temp.c
# 2010/06/11  bujianhui  ע�͵�U��B�ļ��꣬�Ƚ�û�����壬��Ŀǰ��������Ѿ���С
# 2010/06/28  bujianhui  �����ļ�macroNB_update_tmp.txt\macroNB_dif.txt��·��
#                        �����·����Ϊ�ɵ�ǰ�ļ�·���Ʋ⣬��ǿ�Զ༶Ŀ¼����ʱ����Ӧ��
# 2010/07/05  bujianhui  ��U->B������Ŀ���֧��Ϊ�������ļ��ж�ȡ
# 2010/07/15  bujianhui  ����3�������ǩ�ļ�����һ����ǩ�������ƶ���ǩѡ��
# 2010/07/22  bujianhui  ����6��֧�ִ���ȫ�ֱ�ǩ
# 2010/11/25  bujianhui  ����12:֧�ִ���˽�з�֧
###############################################################################

$global_label_VOB = "SuperNodeB_ADMIN";##����ȫ�ֱ�ǩ���õ�VOB��������ͬ��Ŀ��ͬ��TD����ΪSuperNodeB_ADMIN


#--- Initialise constants and variables ----
# ��ȡ��ǰ�ļ����ڵ�·����$0��ʾ��ǰ�ļ���·����
@get_file_dir = split(execute_file, $0);
# �õ�macroNB_update_tmp��macroNB_dif��branch_name��·��
$tmp_file = $get_file_dir[0]."macroNB_update_tmp.txt";
$dif_file = $get_file_dir[0]."macroNB_dif.txt";
$branch_name_file = $get_file_dir[0]."branch_name.txt";

##---������ļ�����һ����ǩ��ģʽѡ��
if ($ARGV[0] == 33)
{
    print " ��ѡ�����ģʽ(���ǩA���ļ����ϱ�ǩC)��\n";
    print "      1 :����ļ��Ѿ����ڱ�ǩC, ���ƶ���ǩC��\n";
    print "      2 :����ļ��Ѿ����ڱ�ǩC, �ƶ���ǩC����ǩA���ڽڵ㣻\n";
    
    $add_another_label_model=<STDIN>;
    
    if (($add_another_label_model != 1) && ($add_another_label_model != 2))
    {
      die "    !!!��������\n\n";
    }
   
}

#��������$ARGV[1]�����õ�U->B������Ŀ������֧
if ($ARGV[0] == 44)
{
  #�򿪱����֧�����ļ�branch_name.txt
  open(BRANCH_FILE, $branch_name_file);
  $icnt = 0;#��ʱ������ʼ��
  $dev_pname = "NULL";
  
  #�����ļ�ÿһ�У�
  while (defined ($branch_name = <BRANCH_FILE>))
  {
    $icnt++;
    $branch_name=~s{\n}{}g;
    
    #�ҵ�ָ���У���Ŀ���֧����ֵ
    if ($icnt == $ARGV[1])
    {
      $dev_pname=$branch_name;
      print "  ���Է�֧:$branch_name����U->B��������\n";
      $dev_pname=~s{\\}{/}g;#Perl��·��б����Window���෴��
    }  
  }
  
  close BRANCH_FILE;#ʹ����ر��ļ�
  
  #���û����������Ӧ�ķ�֧���澯�˳�
  if ($dev_pname eq "NULL")
  {
    die "  Error:U->B������Ŀ������֧ѡ�����\n";
  }
}

#��ѯ��ǩ����
if ($ARGV[0] == 55)
{
  $main_Label = $ARGV[1];
  $pre_Label = $ARGV[2];
  #find . -all -element \"{lbtype_sub(B_EMB5116_V4.10.50.50_DSP_001) && lbtype_sub(U_EMB5116_TDCUP_DTMUC00028492)}\" -version \"lbtype(B_EMB5116_V4.10.50.50_DSP_001)\" -print;
  system("cleartool find .  -element \"{lbtype_sub($main_Label) && lbtype_sub($pre_Label)}\" -version \"lbtype($main_Label)\" -print>$tmp_file")  && die "��ѯ��ǩ����ʧ��";
  die "����ɱ�ǩ$main_Label��$pre_Label������ѯ��������ļ�macroNB_update_tmp.txt\n"
}

#-- amount of file updated ---
$icnt = 0;

#--- read input parameters ---
$private_label = $ARGV[2];
$dev_label = $ARGV[3];

#---����һ���µı�ǩ
if ($ARGV[0] == 66)
{ 
  print " ��ǩ�Ƿ�ȫ����Ч\n  ���롮1��ȫ����Ч������ǰVOB��Ч:\n";
  $mklb_global=<STDIN>;
  
  if ($mklb_global == 1)
  {
    system("cleartool mklbtype -nc  -glo $private_label@../$global_label_VOB") && die"Create New Lable failed.\n";    
    die "Crate Global New Lable Finished.\n\n";
  }
  else
  {
    system("cleartool mklbtype -nc -glo $private_label") && die"Create New Lable failed.\n";
    die "Create New Lable Finished.\n\n";
  }
  
  #ɾ����ǩ
  #rmtype -rmall lbtype:U_EMB5116_TDCUP_BJH@\SuperNodeB_HL
}

#---����һ���µķ�֧
if ($ARGV[0] == 88)
{
  $private_branch = $ARGV[2];
  print " ��ǩ�Ƿ�ȫ����Ч\n  ���롮1��ȫ����Ч������ǰVOB��Ч:\n";
  $mklb_global=<STDIN>;
  
  if ($mklb_global == 1)
  {
    system("cleartool mkbrtype -nc  -glo $private_branch@../$global_label_VOB") && die"Create New Branch failed.\n";    
    die "Crate Global New Branch Finished.\n\n";
  }
  else
  {
    system("cleartool mkbrtype -nc -glo $private_branch") && die"Create New Branch failed.\n";
    die "Create New Branch Finished.\n\n";
  }  
}

#---��ʾCheckout���ļ�������CC������
if ($ARGV[0] == 100)
{
  if ($ARGV[1] == 00)
  {
    system("cleartool lsco -cview -short -rec") && die"Didn't find any checkout file.\n";
    die "\n";
  }
}

#---����֧���½ڵ���
if ($ARGV[0] == 77)
{
  $Branch_Name  = $ARGV[1];
  system("cleartool find . -version \"version(.../$Branch_Name/LATEST)\" -exec \"cleartool mklabel -rep $private_label %CLEARCASE_XPN%\"") && die "Branch Name Error";
                  #  find . -version 'version(.../U_TDB36A_TDCUP_L2FP_TEST/LATEST)' -exec 'cleartool mklabel -rep U_MAC_UPDATE_BUJIANHUI %CLEARCASE_XPN%';
  die "Apply Lable Finished";
}
#--- list file to be updated ----
system("cleartool find . -version \"lbtype($private_label)\" -print>$tmp_file");
#system("cleartool ls >$tmp_file");
#--- open list file ----
open(filename, $tmp_file);
open(Dif_File, "> $dif_file");

#--- iterate each element ----
while (defined ($old_name = <filename>)){
  #--- get path name of element ----
  @my_fields = split(/@@/,$old_name);
  $elem_name = $my_fields[0];
  #--- replace private branch path extension with public dev branch.
  $new_name = $elem_name."@@".$dev_pname."/LATEST";
  
  if ($ARGV[0] == 22)
  {
      #---Del label   
      system("cleartool rmlabel $private_label $old_name") && die "$private_label cannot be removed from $old_name!\n"; 
  }
  
  #---Add another U_label
  if ($ARGV[0] == 33)
  {
      #---���Ŀ���ļ��Ѵ��ڱ�ǩ�������ǩ������ʾ��Ϣ
      if ($add_another_label_model == 1)
      {
        system("cleartool mklabel $dev_label $old_name") && print Dif_File "�ļ�$elem_name�Ѿ����ڱ�ǩ��$dev_label.\n";   
      }
      
      #---���Ŀ���ļ��Ѵ��ڱ�ǩ�����ƶ���ǩ���½ڵ�
      if ($add_another_label_model == 2)
      {
        system("cleartool mklabel -rep $dev_label $old_name") && print Dif_File "���ļ�$elem_name���$dev_labelʱ��������.\n";   
      }
  }
    
  if ($ARGV[0] == 44)
  { 
        #--- (0)Del temp.c ----
    if (-e "temp.c")
    {
    system("del /f temp.c");
    }
      
      #--- (1)Copy and Save ULable File to local ----  
      system("copy $elem_name temp.c") && die "Fail to copy $elem_name to temp.c!\n";
      #--- (2)Check out files ----  
      system("cleartool checkout -nc $new_name") && die "$new_name cannot be checked out!\n";  
      #--- (3)Delete Old BLable files ----   
      system("del $elem_name");
      #--- (4-1)Copy local ULable as Blable files  ----  
      system("copy temp.c $elem_name") && die "Fail to copy temp.c to $elem_name.\n";
      #--- (4-2)Delete  file temp.c   
      system("del /F temp.c") && "Can not delete file temp.c!\n";
      #--- (5)Check in files ----  
      #system("cleartool checkin -nc $elem_name") && die "$elem_name cannot be checked in!\n";
      #--- (6)Apply new label ----  
      if ($dev_label ne "N")#����"N"��ʾ�����
      {
        system("cleartool mklabel -rep $dev_label $elem_name") && die "apply $dev_label to $new_name failed!\n"; 
      }      
      #--- (7)Draw a merge arrow without performing a merge ---- 
      system("cleartool merge -ndata -to $elem_name $old_name") && die "merge $old_name to $elem_name failed!\n";
      #--- (8)Compare merged to file with merged from file ---                                                                                                                                                                           
      #system("cleartool diff $elem_name $old_name >> $dif_file"); 
      #--- (9)Delete old label at old branch ---                                                                                                                                                                                         
      system("cleartool rmlabel $private_label $old_name") && die "$private_label cannot be removed from $old_name!\n";   
      print "$icnt! ---\n"                                                                                                                                                                                                
    }                                                                                                                                                                                                                               


  $icnt++;
}

#--- echo update result to user interface ----
if ($icnt)
{   print "--- $icnt files update succeed! ---\n";
}
else
{   print "ERROR: Label type $private_label or $dev_label not found!\n";
}

close Dif_File;

#find . -version 'version(.../U_TDB36A_TDCUP_L2FP_TEST/LATEST)' -exec 'cleartool mklabel -rep U_MAC_UPDATE_BUJIANHUI %CLEARCASE_XPN%'
#���Ҵ���������ǩ���ļ���find . -all -element '{lbtype_sub(B_EMB5116_V4.10.50.50_DSP_001) && lbtype_sub(U_EMB5116_TDCUP_DTMUC00028492)}' -version "lbtype(B_EMB5116_V4.10.50.50_DSP_001)" -print
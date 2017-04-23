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
# 2010/06/11  bujianhui  删除U2B生成的临时文件temp.c
# 2010/06/11  bujianhui  注释掉U、B文件标，比较没有意义，且目前错误概率已经很小
# 2010/06/28  bujianhui  将对文件macroNB_update_tmp.txt\macroNB_dif.txt的路径
#                        由相对路径改为由当前文件路径推测，增强对多级目录操作时的适应性
# 2010/07/05  bujianhui  将U->B升级的目标分支改为从配置文件中读取
# 2010/07/15  bujianhui  功能3：给打标签文件打另一个标签，增加移动标签选择
# 2010/07/22  bujianhui  功能6：支持创建全局标签
# 2010/11/25  bujianhui  功能12:支持创建私有分支
###############################################################################

$global_label_VOB = "SuperNodeB_ADMIN";##创建全局标签所用的VOB库名，不同项目不同，TD三期为SuperNodeB_ADMIN


#--- Initialise constants and variables ----
# 提取当前文件所在的路径，$0表示当前文件的路径，
@get_file_dir = split(execute_file, $0);
# 得到macroNB_update_tmp、macroNB_dif、branch_name的路径
$tmp_file = $get_file_dir[0]."macroNB_update_tmp.txt";
$dif_file = $get_file_dir[0]."macroNB_dif.txt";
$branch_name_file = $get_file_dir[0]."branch_name.txt";

##---给打标文件打另一个标签，模式选择
if ($ARGV[0] == 33)
{
    print " 请选择打标的模式(打标签A的文件打上标签C)：\n";
    print "      1 :如果文件已经存在标签C, 不移动标签C；\n";
    print "      2 :如果文件已经存在标签C, 移动标签C到标签A所在节点；\n";
    
    $add_another_label_model=<STDIN>;
    
    if (($add_another_label_model != 1) && ($add_another_label_model != 2))
    {
      die "    !!!错误输入\n\n";
    }
   
}

#根据输入$ARGV[1]索引得到U->B升级的目标主分支
if ($ARGV[0] == 44)
{
  #打开保存分支名的文件branch_name.txt
  open(BRANCH_FILE, $branch_name_file);
  $icnt = 0;#临时变量初始化
  $dev_pname = "NULL";
  
  #遍历文件每一行，
  while (defined ($branch_name = <BRANCH_FILE>))
  {
    $icnt++;
    $branch_name=~s{\n}{}g;
    
    #找到指定行，对目标分支名赋值
    if ($icnt == $ARGV[1])
    {
      $dev_pname=$branch_name;
      print "  将对分支:$branch_name进行U->B升级……\n";
      $dev_pname=~s{\\}{/}g;#Perl中路径斜线与Window下相反；
    }  
  }
  
  close BRANCH_FILE;#使用完关闭文件
  
  #如果没有索引到对应的分支，告警退出
  if ($dev_pname eq "NULL")
  {
    die "  Error:U->B升级中目标主分支选择错误\n";
  }
}

#查询标签交集
if ($ARGV[0] == 55)
{
  $main_Label = $ARGV[1];
  $pre_Label = $ARGV[2];
  #find . -all -element \"{lbtype_sub(B_EMB5116_V4.10.50.50_DSP_001) && lbtype_sub(U_EMB5116_TDCUP_DTMUC00028492)}\" -version \"lbtype(B_EMB5116_V4.10.50.50_DSP_001)\" -print;
  system("cleartool find .  -element \"{lbtype_sub($main_Label) && lbtype_sub($pre_Label)}\" -version \"lbtype($main_Label)\" -print>$tmp_file")  && die "查询标签交集失败";
  die "已完成标签$main_Label、$pre_Label交集查询，结果见文件macroNB_update_tmp.txt\n"
}

#-- amount of file updated ---
$icnt = 0;

#--- read input parameters ---
$private_label = $ARGV[2];
$dev_label = $ARGV[3];

#---创建一个新的标签
if ($ARGV[0] == 66)
{ 
  print " 标签是否全局有效\n  输入‘1’全局有效，否则当前VOB有效:\n";
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
  
  #删除标签
  #rmtype -rmall lbtype:U_EMB5116_TDCUP_BJH@\SuperNodeB_HL
}

#---创建一个新的分支
if ($ARGV[0] == 88)
{
  $private_branch = $ARGV[2];
  print " 标签是否全局有效\n  输入‘1’全局有效，否则当前VOB有效:\n";
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

#---显示Checkout的文件，采用CC自身函数
if ($ARGV[0] == 100)
{
  if ($ARGV[1] == 00)
  {
    system("cleartool lsco -cview -short -rec") && die"Didn't find any checkout file.\n";
    die "\n";
  }
}

#---给分支最新节点打标
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
      #---如果目标文件已存在标签，不打标签给出提示信息
      if ($add_another_label_model == 1)
      {
        system("cleartool mklabel $dev_label $old_name") && print Dif_File "文件$elem_name已经存在标签：$dev_label.\n";   
      }
      
      #---如果目标文件已存在标签，则移动标签到新节点
      if ($add_another_label_model == 2)
      {
        system("cleartool mklabel -rep $dev_label $old_name") && print Dif_File "给文件$elem_name打标$dev_label时发生错误.\n";   
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
      if ($dev_label ne "N")#等于"N"表示不打标
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
#查找打了两个标签的文件：find . -all -element '{lbtype_sub(B_EMB5116_V4.10.50.50_DSP_001) && lbtype_sub(U_EMB5116_TDCUP_DTMUC00028492)}' -version "lbtype(B_EMB5116_V4.10.50.50_DSP_001)" -print
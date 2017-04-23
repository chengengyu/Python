##############################################################################
# FILE:     newCodeMerge.pl
# AUTHOR:   bujianhui, TDCUP Group, SW2 Dep.
# PURPOSE:  merge files with private label to dev branch and
#           apply public label to the latter.
# ARGV[0]:  NULL
# ARGV[1]:  待升级的主分支索引，是文件branch_name.txt中的行号
# ARGV[2]:  指示需要升级文件的标签
# ARGV[3]:  归并到主分支上后打上的标签
# COMMENTS: 
# HISTORY:
# 2011/03/30  bujianhui  创建文件：该文件实现的归并不需要限制目标分支路径相同，只要给出分支名即可
#                        同时如果不存在目标分支，将可帮助自动创建分支
#
###############################################################################

#--- Initialise constants and variables ----
# 提取当前文件所在的路径，$0表示当前文件的路径，
@get_file_dir = split(newCodeMerge, $0);
# 得到macroNB_update_tmp、macroNB_dif、branch_name的路径
$tmp_file = $get_file_dir[0]."macroNB_update_tmp.txt";
$dif_file = $get_file_dir[0]."macroNB_dif.txt";
$branch_name_file = $get_file_dir[0]."branch_name.txt";

#---ini variable
$icnt= 0;

#--- read input parameters ---
$private_label = $ARGV[2];
$dev_label     = $ARGV[3];


#根据输入$ARGV[1]索引得到U->B升级的目标主分支

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
    
    $dev_pname =~s{.*/([^/]+)$}{$1}g;
    print "TEST: $dev_pname\n";
    last;
  }  
}

close BRANCH_FILE;#使用完关闭文件

#如果没有索引到对应的分支，告警退出
if ($dev_pname eq "NULL")
{
  die "  Error:U->B升级中目标主分支选择错误\n";
}


#查询需要升级但无目标主分支的文件；

#$dev_pname, $private_label
system("cleartool find .  -element \"{!brtype($dev_pname) && lbtype_sub($private_label)}\" -version \"lbtype($private_label)\" -print>$tmp_file")  && print "Error: 查询需要升级但无目标主分支的文件\n";

if (!(-z $tmp_file))
{
	print "以下文件需要升级，但不存在目标分支$dev_pname: \n";
	system("type $tmp_file ");
	print "\n";
	print "如果以上文件需要拉出分支$dev_pname升级，请输入拉分支的基线标签: \n";
	print "tips：如果跳过以上文件不升级，输入'N'(大写)\n";
	
	$mkbrank_base_label=<STDIN>;#从屏幕输入拉分支的基线标签
	
	$mkbrank_base_label =~ s{\s}{}g;
	print "$mkbrank_base_label";
	if ($mkbrank_base_label !~ m{^\b[N]\b})
	{
	  print "   开始拉分支:\n"
		&MK_Branch_Dif($dev_pname, $private_label, $mkbrank_base_label);			
	}
}

#--- list file to be updated ----
system("cleartool find .  -element \"{brtype($dev_pname) && lbtype_sub($private_label)}\" -version \"lbtype($private_label)\" -print>$tmp_file")  && die "Error in getting update files.\n";
system("cleartool find .  -element \"{brtype($dev_pname) && lbtype_sub($private_label)}\" -version \"version(.../$dev_pname/LATEST)\" -print>$dif_file")  && die "Error in getting update files.\n";

#--- open list file ----
open(TMP_FILE, $tmp_file);
open(DIF_FILE, $dif_file);

$icnt= 0;
#--- iterate each element ----
while (defined ($old_name = <TMP_FILE>))
{
	  @my_fields = split(/@@/,$old_name);
	  $elem_name = $my_fields[0];
	  #--- replace private branch path extension with public dev branch.
	  #$new_name = $elem_name."@@".$dev_pname."/LATEST";
	  $new_name = <DIF_FILE>;
	  
	  @my_fields = split(/@@/,$new_name);
	  $new_elem_name = $my_fields[0];	
	  if ($new_elem_name ne $elem_name)
	  {
	  	die "   ERROR: 请对比文件$tmp_file与$dif_file\n";
	  }  
	  
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
      system("cleartool mklabel -rep $dev_label $elem_name") && die "apply $dev_label to $elem_name failed!\n"; 
    }      
    #--- (7)Draw a merge arrow without performing a merge ---- 
    system("cleartool merge -ndata -to $elem_name $old_name") && die "merge $old_name to $elem_name failed!\n";
    #--- (8)Compare merged to file with merged from file ---                                                                                                                                                                           
    #system("cleartool diff $elem_name $old_name >> $dif_file"); 
    #--- (9)Delete old label at old branch ---                                                                                                                                                                                         
    system("cleartool rmlabel $private_label $old_name") && die "$private_label cannot be removed from $old_name!\n";   
    print "$icnt! ---\n";                                                                                                                                                                                            
                                                                                                                                                                                                                             
    $icnt++;
}

#--- echo update result to user interface ----
if ($icnt)
{   print "--- $icnt files update succeed! ---\n";
}
else
{   print "ERROR: Label type $private_label or $dev_label not found!\n";
}

close TMP_FILE;
close DIF_FILE;

#find . -version 'version(.../U_TDB36A_TDCUP_L2FP_TEST/LATEST)' -exec 'cleartool mklabel -rep U_MAC_UPDATE_BUJIANHUI %CLEARCASE_XPN%'
#查找打了两个标签的文件：find . -all -element '{lbtype_sub(B_EMB5116_V4.10.50.50_DSP_001) && lbtype_sub(U_EMB5116_TDCUP_DTMUC00028492)}' -version "lbtype(B_EMB5116_V4.10.50.50_DSP_001)" -print


#给需要升级但无目标分支的文件拉出分支
## $Paramenter[0]: 目标分支名
## $Paramenter[1]：升级的源标签
## $Paramenter[2]：拉分支的基线标签
## 说明：排除了数值赋初值的情况
sub MK_Branch_Dif
{
	
	my @Paramenter=@_;
  $des_branch_name = $Paramenter[0];
  $src_label_name = $Paramenter[1];
  $base_labe_name = $Paramenter[2];
  
  print "des_branch_nam: $des_branch_nam\n";
  print "src_label_name: $src_label_name\n";
  print "base_labe_name: $base_labe_name\n";
  
  #die "test/n";
	system("cleartool find .  -element \"{!brtype($des_branch_name) && lbtype_sub($src_label_name)}\" -version \"lbtype($base_labe_name)\" -print>$tmp_file")  && die "Error in fuction: MK_Branch_Dif.\n";

	open(TMP_FILE, $tmp_file);
	
	while (defined ($base_elem = <TMP_FILE>))
	{
	  @my_fields = split(/@@/,$old_name);
	  $elem_name = $my_fields[0];
	      
    print "mkbranch from $old_name.\n";
    system("cleartool mkbranch  -nco -nc $des_branch_name $base_elem") && print "Create $des_branch_name from $base_elem failed!\n";  	                                                                                                                                                                                                                  
		#system("cleartool update -print $elem_name");
	}
  close TMP_FILE;    
}
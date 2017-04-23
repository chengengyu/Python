##############################################################################
# FILE:     newCodeMerge.pl
# AUTHOR:   bujianhui, TDCUP Group, SW2 Dep.
# PURPOSE:  merge files with private label to dev branch and
#           apply public label to the latter.
# ARGV[0]:  NULL
# ARGV[1]:  ������������֧���������ļ�branch_name.txt�е��к�
# ARGV[2]:  ָʾ��Ҫ�����ļ��ı�ǩ
# ARGV[3]:  �鲢������֧�Ϻ���ϵı�ǩ
# COMMENTS: 
# HISTORY:
# 2011/03/30  bujianhui  �����ļ������ļ�ʵ�ֵĹ鲢����Ҫ����Ŀ���֧·����ͬ��ֻҪ������֧������
#                        ͬʱ���������Ŀ���֧�����ɰ����Զ�������֧
#
###############################################################################

#--- Initialise constants and variables ----
# ��ȡ��ǰ�ļ����ڵ�·����$0��ʾ��ǰ�ļ���·����
@get_file_dir = split(newCodeMerge, $0);
# �õ�macroNB_update_tmp��macroNB_dif��branch_name��·��
$tmp_file = $get_file_dir[0]."macroNB_update_tmp.txt";
$dif_file = $get_file_dir[0]."macroNB_dif.txt";
$branch_name_file = $get_file_dir[0]."branch_name.txt";

#---ini variable
$icnt= 0;

#--- read input parameters ---
$private_label = $ARGV[2];
$dev_label     = $ARGV[3];


#��������$ARGV[1]�����õ�U->B������Ŀ������֧

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
    
    $dev_pname =~s{.*/([^/]+)$}{$1}g;
    print "TEST: $dev_pname\n";
    last;
  }  
}

close BRANCH_FILE;#ʹ����ر��ļ�

#���û����������Ӧ�ķ�֧���澯�˳�
if ($dev_pname eq "NULL")
{
  die "  Error:U->B������Ŀ������֧ѡ�����\n";
}


#��ѯ��Ҫ��������Ŀ������֧���ļ���

#$dev_pname, $private_label
system("cleartool find .  -element \"{!brtype($dev_pname) && lbtype_sub($private_label)}\" -version \"lbtype($private_label)\" -print>$tmp_file")  && print "Error: ��ѯ��Ҫ��������Ŀ������֧���ļ�\n";

if (!(-z $tmp_file))
{
	print "�����ļ���Ҫ��������������Ŀ���֧$dev_pname: \n";
	system("type $tmp_file ");
	print "\n";
	print "��������ļ���Ҫ������֧$dev_pname����������������֧�Ļ��߱�ǩ: \n";
	print "tips��������������ļ�������������'N'(��д)\n";
	
	$mkbrank_base_label=<STDIN>;#����Ļ��������֧�Ļ��߱�ǩ
	
	$mkbrank_base_label =~ s{\s}{}g;
	print "$mkbrank_base_label";
	if ($mkbrank_base_label !~ m{^\b[N]\b})
	{
	  print "   ��ʼ����֧:\n"
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
	  	die "   ERROR: ��Ա��ļ�$tmp_file��$dif_file\n";
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
    if ($dev_label ne "N")#����"N"��ʾ�����
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
#���Ҵ���������ǩ���ļ���find . -all -element '{lbtype_sub(B_EMB5116_V4.10.50.50_DSP_001) && lbtype_sub(U_EMB5116_TDCUP_DTMUC00028492)}' -version "lbtype(B_EMB5116_V4.10.50.50_DSP_001)" -print


#����Ҫ��������Ŀ���֧���ļ�������֧
## $Paramenter[0]: Ŀ���֧��
## $Paramenter[1]��������Դ��ǩ
## $Paramenter[2]������֧�Ļ��߱�ǩ
## ˵�����ų�����ֵ����ֵ�����
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
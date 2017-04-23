##############################################################################
# FILE:     update.pl
# AUTHOR:   bujianhui, L2FP Group, SW2 Sec.
# PURPOSE:  merge files with private label to dev branch and
#           apply public label to the latter.
# ARGV[0]:  NULL
# ARGV[1]:  specify  file name. if equal "ALL", mkbanch form all files
# ARGV[2]:  label name , looks like U_XXX_YYY_NNN
# ARGV[3]:  branch name
# COMMENTS: 
###############################################################################
@get_file_dir = split(mkbranch, $0);
# 得到macroNB_update_tmp、macroNB_dif、branch_name的路径
$tmp_file = $get_file_dir[0]."macroNB_update_tmp.txt";
$dif_file = $get_file_dir[0]."macroNB_dif.txt";

#-- pname of public development branch for version 2---

#-- amount of file updated ---
$icnt = 0;

#--- read input parameters ---
$sp_file_name  = $ARGV[1];
$private_label = $ARGV[2];
$new_branch    = $ARGV[3];

$All_label_file_flag = 0;

if ($sp_file_name =~m{ALLALL})
{
   $All_label_file_flag = 1; 	
}

print "sp_file: $sp_file_name\n";
print "private_label $private_label\n";
print "new_branch $new_branch\n";

#--- add full file regular expression --
$sp_file_name = "\\\\".$sp_file_name."\\\@\\\@";

#--- list file to be updated ----
system("cleartool find . -version \"lbtype($private_label)\" -print>$tmp_file");
#system("cleartool ls >$tmp_file");
#--- open list file ----
open(filename, $tmp_file);
open(Dif_File, "> $dif_file");

#--- iterate each element ----
while (defined ($old_name = <filename>)){

	#给指定的文件拉分支	
	if ($All_label_file_flag == 0)
	{ 
			#print "Current Fiel: $old_name\n";
	    if ($old_name=~m{$sp_file_name})
	    {
	      #mkbranch  -nc $branch_name $old_name	     
	      print "Start mkbranch from $old_name.\n";
	      system("cleartool mkbranch  -nco -nc $new_branch $old_name") && print "Create $new_branch failed!\n";
	      $icnt++;
	      last;
	    }        	                                                                                                                                                                                            
  }  
  
  #给打标签的所有文件拉分支
  if ($All_label_file_flag == 1)  
  {
      print "Start mkbranch from $old_name.\n";
      system("cleartool mkbranch  -nco -nc $new_branch $old_name") && print "Create $new_branch failed!\n";  	
			$icnt++;
  }                                                                                                                                                                                                                         
}

#--- echo update result to user interface ----
if ($icnt)
{   print "--- Mkbranch at $icnt files! ---\n";
}
else
{   print "ERROR: Label type $private_label or branch type $dev_label not found!\n";
}

close Dif_File;

#find . -version 'version(.../U_TDB36A_TDCUP_L2FP_TEST/LATEST)' -exec 'cleartool mklabel -rep U_MAC_UPDATE_BUJIANHUI %CLEARCASE_XPN%'
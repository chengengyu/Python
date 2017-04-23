##############################################################################
# FILE:     OpCheckoutElmt.pl
# AUTHOR:   bujianhui, TDCUP Group, SW2 Dep.
# PURPOSE:  operate on checkout elements
# 
# PARAMETER:          
#	  ARGV[0]:  "LS_CO"     list checkout element in current view
#	            "CO_APPLY_LABEL"  apply label to checkout files
#	            "CHECK_IN"  check in all element that have been checked out in current view
#	            "UN_CO"     Undo Checkout
#	            "APPLY_TDCUP_V4_B_LABEL"   apply B label of BPOE1 & PLP for TDCUP group
#	  ARGV[1]:  Comment for checkin vision / PLP label name("ARGV[0]:  APPLY_TDCUP_V4_B_LABEL")
#	  ARGV[2]:  label name / BPOE1 label name("ARGV[0]:  APPLY_TDCUP_V4_B_LABEL")
# COMMENTS: 
# HISTORY:
#   2011/04/14  bujianhui  Create file. 
#                        
#
###############################################################################

#--- Initialise constants and variables ----
# 提取当前文件所在的路径，$0表示当前文件的路径，
@get_file_dir = split(OpCheckoutElmt, $0);
# 得到macroNB_update_tmp、macroNB_dif、branch_name的路径
$tmp_file = $get_file_dir[0]."macroNB_update_tmp.txt";

#---ini variable
$icnt= 0;
$plp_file_cnt = 0;
$bpoe1_file_cnt = 0;

#--- read input parameters ---
$op_model   = $ARGV[0];
$ci_comment = $ARGV[1];
$label_name = $ARGV[2];
$label_name =~ s{\s}{}g;

#write check out file to temp file
#open tmep file handle
open(STDERR, ">&STDOUT");
open(STDOUT, "> $tmp_file");

#write check out file element to file handle
system("cleartool lsco -rec -cview -fmt \"%n@@%Vn\\n\"");

open(STDOUT, ">&STDERR");

print "   Checkout节点如下：\n";
system("type $tmp_file");
print "\n";

#open tmep file handle
open(CHECKOUT_FILE, $tmp_file);

#iteration all check out file
while (defined ($co_file_name = <CHECKOUT_FILE>))
{
  $icnt++;
  
  $co_file_name =~ s{\s}{}g;
  
  #apply label to the checkout file
  if ($op_model eq "CO_APPLY_LABEL")
  {
    system("cleartool mklabel -replace $label_name $co_file_name");
  }  
  
  #check in the checkout file
  if ($op_model eq "CHECK_IN")
  {
  	$ci_comment =~ s{\s}{}g;
    system("cleartool checkin -c $ci_comment $co_file_name");
  }
  
  if ($op_model eq "UN_CO")
  {
  	system("cleartool uncheckout $co_file_name");
  }
  
   #TDCUP组四期代码打B标
  if($op_model eq "APPLY_TDCUP_V4_B_LABEL")
  {
  	#PLP文件打标
  	if ((($co_file_name =~ m{BPOE_L2\\Inc}) 
  	      || ($co_file_name =~ m{BPOE_L2\\Src}) 
  	      || ($co_file_name =~ m{BPOE_L2\\MAC_ul})
  	      || ($co_file_name =~ m{BPOE_L2\\MAC_dl\\Inc})
  	      || ($co_file_name =~ m{BPOE_L2\\MAC_dl\\MAC_sd}))
  	    && ($co_file_name !~ m{mcu})
  	    && 1)
  	{
  		#print "PLP: $file\n";
      $label_name = $ARGV[1];
      system("cleartool mklabel -replace $label_name $co_file_name");
      $plp_file_cnt++;    		
  	}
  	#BCPE1文件打标
  	if ((($co_file_name =~ m{BPOE_L2\\Inc}) 
  	      || ($co_file_name =~ m{BPOE_L2\\Src}) 
  	      || ($co_file_name =~ m{BPOE_L2\\FP})
  	      || ($co_file_name =~ m{BPOE_L2\\MAC_dl\\Inc})
  	      || ($co_file_name =~ m{BPOE_L2\\MAC_dl\\MAC_qm}))
  	    && ($co_file_name !~ m{dsp})
  	    && 1)
  	{
  		#print "BCPE1: $file\n";
      $label_name = $ARGV[2];
      system("cleartool mklabel -replace $label_name $co_file_name");
      $bpoe1_file_cnt++;    		
  	}    	
  }  
}

#close file handle
close CHECKOUT_FILE;

if ($op_model eq "LS_CO")
{
	print "  找到$icnt个Checkout的文件\n";
}

if ($op_model eq "CO_APPLY_LABEL")
{
   print "  合计给$icnt个文件打标$label_name\n";
}

if ($op_model eq "CHECK_IN")
{
   print "  合计check in $icnt个文件\n ";
}

if ($op_model eq "UN_CO")
{
   print "  合计undo checkout $icnt个文件\n ";
}

if($op_model eq "APPLY_TDCUP_V4_B_LABEL")
{
	print "  合计给$plp_file_cnt个文件打标$ARGV[1]\n";
	print "  合计给$bpoe1_file_cnt个文件打标$ARGV[2]\n";
}
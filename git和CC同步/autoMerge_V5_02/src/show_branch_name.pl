@get_file_dir = split(show_branch_name, $0);
# 得到branch_name.txt的路径
$branch_name_file = $get_file_dir[0]."/branch_name.txt";

open(BRANCH_FILE, $branch_name_file);
$icnt = 0;

while (defined ($branch_name = <BRANCH_FILE>)){
  $icnt++;
  
  print "     $icnt: $branch_name";
  #$branch_name=~s{\n}{}g;
  #print "$icnt: $branch_name";
}
print "\n";

close BRANCH_FILE;
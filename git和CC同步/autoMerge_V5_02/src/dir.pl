######COPYRIGHT DaTang Mobile Communications Equipment CO.,LTD#####
######2010/04/06  卜建辉   创建文件
######2010/04/15  卜建辉   修改(OSP_STRU_MSGHEAD * *)->(OSP_STRU_MSGHEAD **)
######2010/04/17  卜建辉   增加逻辑表达式中将“==”误写为“=”的判断
######2010/04/21  卜建辉   修改宏定义中将负数的减号与数字中添加了多余空格问题 #PEBASE - 105 -> #PEBASE -105
######2010/04/21  卜建辉   修改 [ * pu8Index] -> [*pu8Index]
######2010/04/22  卜建辉   修改","向前紧随
######2010/04/22  卜建辉   修改重叠注释的替换方式 
######2010/05/24  卜建辉   将替换表达式中的A-z改为A-Za-z，测试表明perl不是使用标准ASCI码,大小写字母不连续
######2010/06/12  卜建辉   删除生成的临时文件temp.file
######2010/06/23  卜建辉   增加规范性检查模式，需同步修改CC_Tool.bat
######2010/06/23  卜建辉   增加列出可读写文件，需同步修改CC_Tool.bat
######2010/07/01  卜建辉   修改“去掉)前面的空格”中误将)写为了(
######2010/07/02  卜建辉   ,\;后加空格扩展
######2010/07/05  卜建辉   去掉，前面的空格 
######2010/07/05  卜建辉   处理强制类型转换
######2010/07/05  卜建辉   解决将宏定义取地址中地址符”&“后加空格问题
######2010/07/05  卜建辉   将（逻辑表达式中将“==”误写为“=”的）改为不修改，只提示
######2010/07/06  卜建辉   取消整行为注释时对嵌套注释的处理
######2010/07/06  卜建辉   对统计后的输出提示进行分类
######2010/07/07  卜建辉   加入判断头文件包含是否使用了""
######2010/07/07  卜建辉   加入判断switch与default是否配对
######2010/07/08  卜建辉   注释掉”File $fileName is OK“，最后的统计已经起到了这个作用了
######2010/07/08  卜建辉   加入检查if/for/while/switch后是否直接接语句或{
######2010/07/12  卜建辉   加入宏函数括号不完备检查：检查第一个参数是否全部加了括号
######2010/07/14  卜建辉   加入"{"是否独占一行的判断
######2010/07/19  卜建辉   加入宏定义#defien  xx     xxx + xxx无括号的判断
######2010/07/20  卜建辉   加入代码注释量统计，低于门限值的告警
######2010/08/10  卜建辉   加入全局变量命名规范性检查-- g开头，不能使用int\short\char
######2010/08/10  卜建辉   加入//注释的检查，放在函数CheckGlobalVariable中
######2010/08/10  卜建辉   加入一行有多个变量声明或定义的情况，放在函数CheckGlobalVariable中
######2010/08/10  卜建辉   加入检查是否使用了NULL，放在函数CheckGlobalVariable中
######2010/08/10  卜建辉   加入指针符未与变量紧随的检查，不支持形参检查
######2010/08/11  卜建辉   加入判断头文件保护是否规范
######2010/08/11  卜建辉   加入未在定义时初始化的全局变量的统计，结果存入文件UnInitVarInDef.txt
######2010/08/12  卜建辉   将规范性检查结果统一输出到文件
######2010/08/30  卜建辉   增加指针符与变量紧随判断、缩进未4的倍数的开关
######2010/08/30  卜建辉   增加指针符与变量紧随的自动修改
######2010/08/31  卜建辉   for (     ;
######2010/08/31  卜建辉   检查模式下对“mac\inc”的误检
######2010/08/31  卜建辉   宏定义多行的检查问题
######2010/09/02  卜建辉   (Uint)&start_cycle
######2010/09/13  卜建辉   全局常量的检查是否要求一致
######2010/09/13  卜建辉   去掉非CHECK_LIST检查项
######2010/11/25  卜建辉   功能13：增加给指定文件打标
######2011/02/17  排除对第三方文件的规范性检查
######2011/02/17  修正for循环换行时对于“if/for/while/switch是否与语句在同一行”的误判
######2011/02/17  修正打印中不能出现NULL的问题；
######2011/04/02  增加CheckIn功能
######2011/04/13  取消CheckIn和UndoCheckout操作时对文件扩展名的判断

use warnings; 
use File::Find; 

my $Start_valid = 0;
my $In_line = 0;
my $Out_line = 0;
my @array;
my $result = 0;
my $back_name=0;
my $line_cnt = 0;
my $Modify_Flag = 0;
my $find_logical_if = 0;
my ($pfile_name, $dircnt, $filecnt) = (0, 0, 0); 
my $unstandard_file_cnt = 0;
my $switch_cnt = 0;
my $s_default_cnt = 0;
my $define_x;
my @defien_arr;
my $macro_line;
my @macro_array;
my $comment_line_cnt = 0;#注释行数目
my $code_line_cnt    = 0;#代码行数目
my $comment_code_ratio = 0;#注释率 
my $commCodeRatioTh    = 30;#注释率门限值，低于门限将告警
my $dev_comment_line  = 0;
my $need_indent = 0; #缩进标识
my $check_indent_flag = 0; #是否检查缩进不对问题，1检查，0不检查
my $check_ptrVar_flag = 0; #是否检查指针符与变量紧随问题，1检查，0不检查
my $first_line = 0;
my $first_line_flag = 0;
my $second_line = 0;
my $second_line_flag = 0;
my $last_line = 0;

my $un_init_var_cnt = 0;
my $unregu_flag = 0;
my $unregu_file_cnt  = 0;
my $comment = "";

use Cwd;


##函数记录文件的第一行、第二行、最后一行
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
## 说明：为头文件保护判断做准备
sub UpdataHeadFilePara()
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #去除换行  
  
  #只保存有效代码行
  if ($code_line !~ m{^\s*$})
  {
    #保存文件第二行有效代码行，头文件应该是 #define MACE_MACRO_H
    if (($first_line_flag == 1) && ($second_line_flag == 0))
    {
      $second_line = $code_line;
      $second_line_flag = 1;
    } 
 
    #保存文件第一行有效代码行，头文件应该是 #ifndef MACE_MACRO_H
    if ($first_line_flag == 0)
    {
      $first_line = $code_line;
      $first_line_flag = 1;
    }
   
    
    #保存文件最后一行有效代码行
    $last_line = $code_line;
  }
}

##函数判断头文件保护是否规范
## $Paramenter[0]: 文件名
## 说明：
##      1. 第一行应为#ifndef MAC_MACRO_H;
##      2. 第二行应为#define MAC_MACRO_H;
##      3. 最后一行应为#endif;
##      4. 文件名为mac_macro.h则宏名应为MAC_MACRO_H；
##      以上规则基于C语言编程规范中描述：头文件保护开头(#ifndef 文件名_H #define 文件名_H);
sub CheckHeadFilePara()
{
  my @Paramenter=@_;
  my $define_file_name = 0;
  
  if ($Paramenter[0] =~ m{\.h})
  {
    $define_file_name = $Paramenter[0];
    $define_file_name =~ s{\.}{_}g;   #由文件名得到宏名
    
    if (($first_line !~ m{ifndef +($define_file_name)}i)
        || ($second_line !~ m{define +($define_file_name)}i)
        || ($last_line !~ m{\#endif}i))
    {
      print CCR_File  "  $Paramenter[0]，请确认头文件保护是否规范\n";
      print CCR_File  "$first_line\n$second_line\n$last_line\n";
      $unregu_flag = 1;
    }
  }
}

##函数判断代码行缩进正确性
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
## 说明：1. $need_indent 为全局变量
##       2. 缩进为4的倍数;
sub CheckIndent()
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #去除换行
  
  if (($need_indent == 1) && ($check_indent_flag == 1))
  {
    if (($code_line !~ /^(( {4})|( {8})|( {12})|( {16})|( {20})|( {24})|( {28})|( {32})|( {36})|( {40})|( {44})|( {48})|( {52})|( {56})|( {60})|( {64}))[^ ]/)
    && ($code_line !~ m{^[^ ]})
    && ($code_line !~ m{^ *$}))
    {
      print CCR_File  "  $Paramenter[0], $line_cnt行，请确认缩进是否正确\n";
      print CCR_File  "$code_line\n";
      $unregu_flag = 1;
    }
  }
  
  if ($code_line =~ m{(;|\{|\}|(\*\/)) *$})
  {
    $need_indent = 1;
    #print "11 $line_cnt\n"
  } 
  if (($code_line !~ m{^ *$}) 
     && ($code_line !~ m{(;|\{|\}|(\*\/)) *$}))
  {
    $need_indent = 0;
  } 
}


##函数实现对非注释行中不规范空格的修改
## 说明：直接修改全局变量
sub RepairBlank()
{
  my @Paramenter=@_;
  my $code_line = $result;#保存修改前的代码行
  
  $result=~s{([A-Za-z0-9]|\)|\])(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[<]+=?|[%]=?|\*)([A-Za-z0-9_]|\(|\*)}{$1 $2 $3}g;
  $result=~s{([A-Za-z0-9]|\)|\])(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[<]+=?|[%]=?)([ ])([A-Za-z0-9_]|\(|\*)}{$1 $2$3$4}g;
  $result=~s{([A-Za-z0-9]|\)|\])([ ]+)(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[%]=?)([A-Za-z0-9_]|\(|\*)}{$1$2$3 $4}g;
  $result=~s{=( *)([&]|\*) *}{=$1$2}g;             #处理 u8 *pu8Num =&u8Num; or u8 u8Num = * u8SfNum
  $result=~s{(\*)( *)(\))( *& *)}{$1$2$3&}g;    #处理 (u8 *) &u32Num;
  if (!($result=~ m{\# ?incl}))                 #排除#include <mian>.h的情况
  {
    $result=~s{([ ])([<]+=?)([A-Za-z0-9_]|\()}{$1$2 $3}g;
  }
  $result=~s{(for|if|switch|while)\(}{$1 \(}g;         #for( -> for (
  $result=~s{(;|,)([A-Za-z0-9_&*(])}{$1 $2}g;          #;,后添加空格
  $result=~s{(\()( +)([A-Za-z0-9_&*]|\()}{$1$3}g;      #去掉(后面的空格
  $result=~s{([A-Za-z0-9_]|\)|\])( +)(\)|;|,)}{$1$3}g; #去掉")"、";"、","前面的空格
  $result=~s{u32(\)) +& +}{u32$1&}g;                   #处理(u32) & u8Num
  $result=~s{(\*)( *)(\*)}{$1$3}g;                     #修改(XXX * *)->(XXX **)
  $result=~s{(^#define *[A-Za-z0-9_]* *)(- *)([A-Za-z0-9]|\()}{$1-$3}g; #PEBASE - 105 -> #PEBASE -105
  $result=~s{\[ *\* *}{[*}g;                           #修改 [ * pu8Index] -> [*pu8Index]
  $result=~s{(^#define +[A-Za-z0-9_]+\([A-Za-z0-9_, ]+\) +)([&]|\*) +}{$1$2}g;##define MFUNC_GET_POINT(x)   &g_struMAC_RL_Info[x]
  $result=~s{(= +\([a-zA-Z_0-9]+\)) +(\*) +}{$1$2}g;   #处理强制类型转换  
  $result =~ s{(^#define[^)]+\) +)& +}{$1&}g;#解决用宏定义取地址中地址符”&“后加空格问题

  if (   ($result=~m{=( *)([&]|\*) *})#处理 u8 *pu8Num =&u8Num; or u8 u8Num = * u8SfNum
      || ($result=~m{(\*)( *)\) *([&]|\*) *})#处理 (u8 *) &u32Num;
      || ($result=~m{(\*)( *)(\*)})#修改(XXX * *)->(XXX **)
      || ($result=~m{(\([a-zA-Z_0-9]+\)) *(\*|[&]) *})#处理强制类型转换 
      || ($result=~m{^#define +[A-Za-z0-9_]+ +[&] +[A-Za-z0-9_]+})
      || ($result=~m{\"})
      || ($result=~m{^ *(return) *[-]}))
  {
    $result = $code_line;
  }
  
  if ($code_line ne $result)
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，是否缺少或多余空格!\n";
    print CCR_File  "$code_line\n";
  }
  
  #检查指针定义时，*是否与变量紧随
  if (($code_line =~ m{^ *(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ *\* +[a-zA-Z0-9_]+ *(;|\[|=)})
      && ($check_ptrVar_flag == 1))
  {
    $result =~ s{([^ ])([*])( +)([^ ])}{$1$3$2$4}g;        
  }
}


##函数实现判断if后面的逻辑表达式是否将“==”误写为“=”
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
## 说明：$find_logical_if 为全局变量
sub IsLogEquWrong()
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #去除换行
  
  if ($find_logical_if == 1)
  {
    if ($code_line=~ m{\{|[;]})#通过 { 判断逻辑表达式部分已经结束
    {
      $find_logical_if = 0;
    }
    else #与上一行一起都还是逻辑表达式部分
    {
      if ($code_line=~ m{[^=!><]=[^=]})
      {             
        print CCR_File  "  $Paramenter[0], $line_cnt行，怀疑逻辑表达式中存在赋值‘=’，请确认是否有误!\n";
        print CCR_File  "    $code_line\n";
        $unregu_flag = 1;
      }
    }
  }
  else 
  {
    if ($code_line=~ m{ *if *\(})
    {
      $find_logical_if = 1;
      if ($code_line=~ m{[^=!><]=[^=]})
      {              
        print CCR_File  "  $Paramenter[0], $line_cnt行，怀疑逻辑表达式中存在赋值‘=’，请确认是否有误!\n";
        print CCR_File  "    $code_line\n";
      }
      
      if ($code_line=~ m{\{|[;]})
      {
        $find_logical_if = 0;
      }            
    }
  }#End 增加逻辑表达式中将“==”误写为“=”的判断
}


##函数实现宏函数中参数是否加括号的检查
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
## 说明：排除用宏函数替换原函数的情况
##       0719加入宏定义#defien  xx     xxx + xxx无括号的判断
sub MacroBracket()
{
  my @Paramenter=@_;
  my $macro_line = $Paramenter[1]; 
  $macro_line =~ s{\n}{}g; #去除换行
  
  ##判断当前行是否是宏函数定义行
  ##    排除用宏函数替换原函数的情况
  if (($macro_line =~ m{define +[a-zA-Z0-9_]+\( *\b([a-zA-Z0-9_]+)\b})
      && ($macro_line !~ m{define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\) +[a-zA-Z0-9_]+ *\([a-zA-Z0-9, ]+\)})
      && ($macro_line !~ m{\[}))#($macro_line !~ m{define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\) +[a-zA-Z0-9_ .->\[\]]+$}))
  {
    ##获取宏函数的第一个参数
    $macro_x=$1;
    ##获取宏函数的函数体部分: 分割后存入了$macro_array[1]
    @macro_array = split(/define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\)/, $macro_line);
    ##判断宏函数函数体中第一个参数是否被括号包围
    if (($macro_array[1] =~ m{[^(\[] *\b($macro_x)\b}) 
        || ($macro_array[1] =~ m{\b($macro_x)\b *[^)\]]})
        || ($macro_line !~ m{define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\) *(\(|\\)})
        || ($macro_line !~ m{(\)|\\) *$}))
    {
      print CCR_File  "  $Paramenter[0], $line_cnt行，请确认宏定义括号是否完备:\n";
      print CCR_File  "$macro_line\n";
      $unregu_flag = 1;
    }
    

  }
  
  ## 宏定义#defien  xx     xxx + xxx无括号的判断
  if (($macro_line =~ m{define +[a-zA-Z0-9_]+ +[a-zA-Z0-9_]+ *[^a-zA-Z0-9_] *(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[<]+=?|\*)})
    || ($macro_line =~ m{define +[a-zA-Z0-9_]+ +-[0-9]}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，请确认宏定义括号是否完备:\n";
    print CCR_File  "$macro_line\n";  
    $unregu_flag = 1;    
  }
  
 
}

##函数判断"{"是否独占一行
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
## 说明：排除了数值赋初值的情况
sub IsBigBracketSingleLine
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #去除换行
  
  if (($code_line =~ m{\{}) && ($code_line !~ m{^\s*\{}) && ($code_line !~ m{= *\{}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，请确认‘{’是否独占一行\n";
    print CCR_File  "$code_line\n";
    $unregu_flag = 1;
  }
  
}

##函数判断if/for/while/switch是否与语句在同一行
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
##  说明：排除了fp_ts中使用while (1);的情况
sub IsKeywordSingleLine
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #去除换行
  
  #1.判断if/for/while/switch是否与语句在同一行
  if (($code_line !~ m{while +\(1\);})
      && (($code_line =~ m{^ *(if|while|switch)[^a-zA-Z0-9_].*; *$}) || ($code_line =~ m{^ *(for).*;.*;.*; *$}))
      && ($code_line !~ m{\} *while}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行, 请确认if/for/while/switch是否与语句在同一行\n";
    print CCR_File  "$code_line\n";
    $unregu_flag = 1;
  } 
}

##函数修复误将文件路径中的斜线前后加空格的问题
##    函数无入口参数，直接修改变量$result
sub UndoFileNameChange
{ 
  if ($result =~ m{\"})
  {
    $result =~ s{ *(\\) *}{$1}g;
  }
  
  if ($result =~ m{\"})
  {
    $result =~ s{ *(\/) *}{$1}g;
  }
}

##函数检查全局变量命名是否规范
## $Paramenter[0]: 文件名
## $Paramenter[1]：文件中当前检查行(已去除注释部分)
##  说明：全局变量必须已g_开头、变量定义不能使用int\short\char
sub CheckGlobalVariable
{ 
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #去除换行
    
  #检查全局变量不以g开头的情况
  #---排除了HL项目中使用stru开头的情况
  if (($code_line =~ m{^(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ +\*?[a-fh-zA-Z_][a-zA-Z0-9_]+ *(;|\[|=)})
       && ($code_line !~ m{^(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ +\*?stru[a-zA-Z0-9_]+ *(;|\[|=)}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，全局变量命名是否规范:\n";
    print CCR_File  "$code_line\n";   
    $unregu_flag = 1;
  }
  
  #统一输出未在定义时初始化的全局变量到文件UnInitVarInDef.txt中
  if (($code_line =~ m{^(static +)?(const +)?[a-zA-Z0-9_]+ +\*?[a-zA-Z0-9_]+ *(;|\[|=)})
      && ($code_line !~ m{=}))
  {
    print UI_File "$Paramenter[0], $line_cnt：$code_line\n";
    $un_init_var_cnt++;
  }
  
  
  #检查使用 int\short\char定义变量的情况，包含局部变量和全局变量的情况，不含形参检查
  if (($code_line =~ m{^ *(extern +)?(static +)?(const +)?(int|short|char) +\*?[a-zA-Z0-9_]+ *(;|\[|=)}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，禁止使用int、short、char定义变量:\n";
    print CCR_File  "$code_line\n";     
  }
  
  # //型注释检查
  if ($code_line =~ m{\/\/})
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，禁止使用\/\/进行注释:\n";
    print CCR_File  "$code_line\n";       
  }
  
  #一行有多个变量定义或声明的情况
  if ($code_line =~ m{^ *(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ +\*?[a-zA-Z0-9_]+ *, *\*? *[a-zA-Z0-9_]+ *(;|\[|=|,)})
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，单行包含多个变量定义或声明：\n";
    print CCR_File  "$code_line\n";      
  }
  
  #检查是否使用NULL
  if (($code_line =~ m{\b(NULL)\b})
      && ($code_line !~ m{\"}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，禁止使用NULL\n";
    print CCR_File  "$code_line\n";   
  }
  
  #检查指针定义时，*是否与变量紧随
  if (($code_line =~ m{^ *(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ *\* +[a-zA-Z0-9_]+ *(;|\[|=)})
     && ($check_ptrVar_flag == 1))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt行，指针符未与变量紧随：\n";
    print CCR_File  "$code_line\n";
    #$Paramenter[1] =~ s{([^ ])([*])( +)([^ ])}{$1$3$2$4}g;        
  }
  
}

sub FileModify
{
  my @Paramenter=@_;
  my $fileName = $Paramenter[0];
  
  my $switch_cnt = 0;
  my $s_default_cnt = 0;
  
  $comment_line_cnt = 0;#注释行数目
  $code_line_cnt    = 0;#代码行数目
  $comment_code_ratio = 0;#注释率
  
  $first_line_flag = 0;#每个文件开始时需初始化
  $second_line_flag = 0;#每个文件开始时需初始化
  
  
  #print "Check file $fileName ...\n";
  #my $dir = $ENV{'PWD'};
  my $dir = getcwd;
  #print "$dir\n";
  #$fileName=~ s{^(\.\/)(.+)}{$2}g;
  $fileName=~ s{(^.*[^a-zA-Z_0-9])([a-zA-Z_][a-zA-Z_0-9]*)(\.)([a-zA-Z_0-9]*)}{$2$3$4}g;
  open(Input, "$fileName") || print "Error happened when try to open $fileName.\n";
  
  #Delete temp.file
  if (-e "temp.file")
  {
    system("del /f temp.file");
  }
  open(Output, "> temp.file");
  
  $Start_valid=0;
  $line_cnt=0;
  $Modify_Flag=0;
  while ($In_line = <Input>)
  {
    $line_cnt++;
    $Out_line = $In_line;
    #处理注释重叠的情况
    if (($Out_line=~m{\*/ */\*}) && ($Out_line=~m{\*/}))
    {
      $Out_line=~s{\*/ */\*}{  }g;#修改重叠注释的替换方式
    }
    
    
    if (0 == $Start_valid)
    {   
      if ($Out_line=~m{/\*})
      {
        $Start_valid=1;
        @array=split(m{/\*}, $Out_line);
        $result=$array[0];
               
        &RepairBlank($fileName, $result);
                        
        #统计switch数目
        if ($result =~ m{switch *\(})
        {
          $switch_cnt++;
        }
        
        #统计default数目
        if ($result =~ m{default *:})
        {
          $s_default_cnt++;
        }
        
        #统计一行是否有两个语句，通过;来判断
        if (($result =~ m{;.*; *$})
            && ($result !~ m{^ *(for)}))
        {
          print CCR_File  "  $fileName, $line_cnt, 是否单行有多个语句：\n";
          print CCR_File  "$result\n";
        }
        
        &IsLogEquWrong($fileName, $result);
        
        &IsKeywordSingleLine($fileName, $result);
        
        &MacroBracket($fileName, $result);
        
        &IsBigBracketSingleLine($fileName, $result);
        
        &UndoFileNameChange();
        
        &CheckIndent($fileName, $result);
        
        &CheckGlobalVariable($fileName, $result);
        
        &UpdataHeadFilePara($fileName, $result);
        
        if ($result !~ m{^ *$})
        {
          $code_line_cnt++;
        }
        
        $result="$result"."/*"."$array[1]"; 
        $Out_line=$result;
        $comment_line_cnt++;
      }
      else
      {
        $result=$Out_line;

        &RepairBlank($fileName, $result);
        
        #统计switch数目
        if ($result =~ m{switch *\(})
        {
          $switch_cnt++;
        }
        
        #统计default数目
        if ($result =~ m{default *:})
        {
          $s_default_cnt++;
        }
        
        #统计一行是否有两个语句，通过;来判断
        if (($result =~ m{;.*; *$})
            && ($result !~ m{^ *(for)})
            && ($result !~ m{\"}))
        {
          print CCR_File  "  $fileName, $line_cnt, 是否单行有多个语句：\n";
          print CCR_File  "$result";
        }    
        
        &IsLogEquWrong($fileName, $result);
        
        &IsKeywordSingleLine($fileName, $result); 
        
        &MacroBracket($fileName, $result);
        
        &IsBigBracketSingleLine($fileName, $result);
        
        &UndoFileNameChange();
        
        &CheckIndent($fileName, $result);
        
        &CheckGlobalVariable($fileName, $result);
        
        &UpdataHeadFilePara($fileName, $result);
        
        if ($result !~ m{^ *$})
        {
          $code_line_cnt++;
        }
              
        $Out_line=$result;
      }
      
      if ($Out_line=~m{\*/})
      {
        $Start_valid=0;
      }
    }
    else
    {
      if ($Out_line=~m{\*/})
      {
        $Start_valid=0;
      } 
      $comment_line_cnt++;  
    }

    #删除TAB建，并输出到屏幕
    if ($Out_line =~ m{\t})
    {
      print CCR_File  "  $fileName, $line_cnt: 本行有Tab键.\n";
      $Out_line =~ s{\t}{    }g;
    }
    
    #删除行尾空格
    $Out_line=~s{ +$}{}g;
    
    
    #取消整行为注释时对嵌套注释的处理     
    if (($In_line =~ m{^ */\*}) && ($In_line =~ m{\*/ */\*}))
    {
      $Out_line = $In_line;
    }
    
    #检查头文件包含是否符合规范
    if ($Out_line =~ m{(^#include +\")})
    {
      print CCR_File  "  $fileName, $line_cnt, 请确认头文件包含是否符合规范：\n";
      print CCR_File  "$Out_line";
    }
    
    #标识是否发生了改变
    if (!($Out_line eq $In_line))
    {
      $Modify_Flag=1;    
    }
    print Output "$Out_line";
  }
  
  if ($switch_cnt != $s_default_cnt)
  {
    print CCR_File  "  $fileName, 'switch'是否都有'default'配对: $switch_cnt,$s_default_cnt\n";
  }
  
  #计算注释率
  if (($code_line_cnt + $comment_line_cnt) == 0)
  {
    $comment_code_ratio = 111;
  }
  else
  {
    $comment_code_ratio = $comment_line_cnt * 100 / ($code_line_cnt + $comment_line_cnt);
  }
  
  #注释率低于门限值，则告警
  if($comment_code_ratio < $commCodeRatioTh)
  {
    $dev_comment_line = $commCodeRatioTh / (100 - $commCodeRatioTh)* $code_line_cnt - $comment_line_cnt;
    print CCR_File  "  $fileName, 文件注释率为$comment_code_ratio%，不达标!! 新增$dev_comment_line行注释可达到标准注释率$commCodeRatioTh%\n";
  }
  
  &CheckHeadFilePara($fileName);

  close(Input);
  close(Output);
  if ($Modify_Flag == 1)
  {
    $unstandard_file_cnt++;
    $back_name=$fileName;
    if ($ARGV[2] == 11)
    {
      unlink($fileName.".bak");
      rename($fileName, $fileName.".bak") || print "rename $fileName error";
      rename("temp.file", $back_name) || print "rename temp.file error";
      print "   File $fileName has been Modified.\n"
    }
    else
    {
      print "   File $fileName need to be modified.\n";
      if (-e "temp.file")
      {
        system("del /f temp.file");
      }
    }
  }
  else
  {
    #print "   File $fileName is OK.\n";
    #Delete temp.file
    if (-e "temp.file")
    {
      system("del /f temp.file");
    }
  }

}

sub DirProcess 
{ 
  my $file = $File::Find::name; 
  

  #排除不需要检查的第三方文件
  $is_third_party_file = 0;

  @get_third_party_files_dir = split("dir.pl", $0);
  # 得到branch_name.txt的路径
  $third_party_files = $get_third_party_files_dir[0]."/third_party_files.txt";
  
  open(THIRD_PARTY_FILES, $third_party_files);
  
  while (defined ($third_party_file_name = <THIRD_PARTY_FILES>))
  {
    $third_party_file_name =~s{\n}{}g;
    if ($file =~m{$third_party_file_name})
    {
      print "$third_party_file_name属于第三方文件，不需要进行规范性检查.\n";
      #print "$file, \n";
      $is_third_party_file = 1;
      last;
    }
  }
   
  close THIRD_PARTY_FILES;
  
  if ($is_third_party_file == 1)
  {
    #print "不检查第三方文件，继续下一文件。\n";
    return;
  }
  #End排除不需要检查的第三方文件
  

  
  $pfile_name=$file;
  $pfile_name=~s{(.+)(\/)([A-Za-z0-9_]+\.)([a-zA-Z0-9]+)$}{$3$4}g;

  if (-f $pfile_name)
  { 
    #1: 对View下所有.c\.h文件(非‘只读’文件)规范性修改; 
    if (($ARGV[0] eq "CR_Mode1") && ($file =~ m{\.(c|h)$}) && (-w $pfile_name))
    {
      &FileModify($file);
      $filecnt++;
    }
    
    #2: 对输入的指定文件进行规范性修改;
    if (($ARGV[0] eq "CR_Mode2") && ($ARGV[1] eq $pfile_name) && (-w $pfile_name))
    {
      print "您指定的文件已经找到，正在进行处理.\n";
      &FileModify($file);
      $filecnt++;
    }
    
    #3: 对View下所有.c\.h文件(含‘只读’文件)规范性检查; 
    if (($ARGV[0] eq "CR_Mode3") && ($file =~ m{\.(c|h)$}))
    {
      &FileModify($file);
      $filecnt++;
    }
    
    #4: 对输入的指定文件进行规范性检查;
    if (($ARGV[0] eq "CR_Mode4") && ($ARGV[1] eq $pfile_name))
    {
      print "您指定的文件已经找到，正在进行处理.\n";
      &FileModify($file);
      $filecnt++;
    }
    
    #给Checkout的文件打标，实际给非‘只读’的文件打标
    if(($ARGV[0] eq "CO_Label") && (-w $pfile_name))
    {
      $label_name = $ARGV[1];
      system("cleartool mklabel -replace $label_name $pfile_name");
      $filecnt++;
    }
    
    #列出可读写文件
    if(($ARGV[0] eq "LSCO_Mode2") && (-w $pfile_name))
    {
      print "$pfile_name\n";
      $filecnt++;
    }
    
    #undo checkout
    if (($ARGV[0] eq "UN_CO_Y") && (-w $pfile_name))
    {
      system("cleartool uncheckout $pfile_name");
      $filecnt++;
    }
    
    #checkin
    if (($ARGV[0] eq "CHECK_IN_Y") && (-w $pfile_name))
    {
      $comment = $ARGV[1];
      $comment =~ s{\s}{}g;
      system("cleartool checkin -c $comment $pfile_name");
      $filecnt++;
    }
    
    #给指定文件打标
    if(($ARGV[0] eq "SpeF_Label") && ($ARGV[1] eq $pfile_name))
    {
      $label_name = $ARGV[2];
      system("cleartool mklabel -replace $label_name $pfile_name");
      $filecnt++;
    }  
    
    #TDCUP组四期代码打B标
    if(($ARGV[0] eq "APPLY_TDCUP_V4_B_LABEL") && (-w $pfile_name))
    {
    	#PLP文件打标
    	if ((($file =~ m{BPOE_L2\/Inc}) 
    	      || ($file =~ m{BPOE_L2\/Src}) 
    	      || ($file =~ m{BPOE_L2\/MAC_ul})
    	      || ($file =~ m{BPOE_L2\/MAC_dl\/Inc})
    	      || ($file =~ m{BPOE_L2\/MAC_dl\/MAC_sd}))
    	    && ($file !~ m{mcu})
    	    && 1)
    	{
    		#print "PLP: $file\n";
        $label_name = $ARGV[1];
        system("cleartool mklabel -replace $label_name $pfile_name");
        $filecnt++;    		
    	}
    	#BCPE1文件打标
    	if ((($file =~ m{BPOE_L2\/Inc}) 
    	      || ($file =~ m{BPOE_L2\/Src}) 
    	      || ($file =~ m{BPOE_L2\/FP})
    	      || ($file =~ m{BPOE_L2\/MAC_dl\/Inc})
    	      || ($file =~ m{BPOE_L2\/MAC_dl\/MAC_qm}))
    	    && ($file !~ m{dsp})
    	    && 1)
    	{
    		#print "BCPE1: $file\n";
        $label_name = $ARGV[2];
        system("cleartool mklabel -replace $label_name $pfile_name");
        $filecnt++;    		
    	}    	
    }  
  } 
  

} 

#chdir("new");

#获取UnInitVarInDef.txt文件全路径名
@get_file_dir = split("dir", $0);
$unInit_file = $get_file_dir[0]."UnInitVarInDef.txt";
$codeCheckReport_file =  $get_file_dir[0]."CodeCheckReport.txt";

open(UI_File, "> $unInit_file");#打开文件UnInitVarInDef.txt
print UI_File "  以下变量未在定义时初始化，需要确认是否统一进行了初始化：\n";#输出到文件UnInitVarInDef.txt

open(CCR_File, "> $codeCheckReport_file");#打开文件CodeCheckReport.txt
print CCR_File "  以下规范性问题需要确认：\n";

find(\&DirProcess, "."); #遍历当前目录下所有文件进行操作

close UI_File; #关闭文件UnInitVarInDef.txt
close CCR_File;#关闭文件CodeCheckReport.txt


#1: 对View下所有.c\.h文件(非‘只读’文件)规范性修改; 
if (($ARGV[0] eq "CR_Mode1") || ($ARGV[0] eq "CR_Mode2"))
{
  print "共检查$filecnt个文件，对$unstandard_file_cnt个文件进行了规范性修改。\n";
}

#3: 对View下所有.c\.h文件(含‘只读’文件)规范性检查;
if (($ARGV[0] eq "CR_Mode3") || ($ARGV[0] eq "CR_Mode4"))
{
  print "共检查$filecnt个文件，$unstandard_file_cnt个文件存在空格问题，可自动修改。\n";
  print "   其它规范性问题见文件：CodeCheckReport.txt";
  
  #显示未在定义时初始化的变量
  if ($un_init_var_cnt != 0)
  {
    system("$unInit_file");
  }
  
  #显示可能存在的规范性问题
  system("$codeCheckReport_file");
}

#给Checkout的文件打标，实际给非‘只读’的文件打标
if(($ARGV[0] eq "CO_Label") && (-w $pfile_name))
{
  print "共对$filecnt个文件打标：$label_name\n";
}

#列出可读写文件
if(($ARGV[0] eq "LSCO_Mode2") && (-w $pfile_name))
{
  print "找到$filecnt个可读写.c/.h文件。\n";
}

#undo checkout
if ($ARGV[0] eq "UN_CO_Y")
{
  print "共将$filecnt个文件进行Undo Checkout操作\n";
}

#屏幕显示一个空格
print "\n";
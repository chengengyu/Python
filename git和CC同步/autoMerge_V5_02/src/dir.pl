######COPYRIGHT DaTang Mobile Communications Equipment CO.,LTD#####
######2010/04/06  ������   �����ļ�
######2010/04/15  ������   �޸�(OSP_STRU_MSGHEAD * *)->(OSP_STRU_MSGHEAD **)
######2010/04/17  ������   �����߼����ʽ�н���==����дΪ��=�����ж�
######2010/04/21  ������   �޸ĺ궨���н������ļ���������������˶���ո����� #PEBASE - 105 -> #PEBASE -105
######2010/04/21  ������   �޸� [ * pu8Index] -> [*pu8Index]
######2010/04/22  ������   �޸�","��ǰ����
######2010/04/22  ������   �޸��ص�ע�͵��滻��ʽ 
######2010/05/24  ������   ���滻���ʽ�е�A-z��ΪA-Za-z�����Ա���perl����ʹ�ñ�׼ASCI��,��Сд��ĸ������
######2010/06/12  ������   ɾ�����ɵ���ʱ�ļ�temp.file
######2010/06/23  ������   ���ӹ淶�Լ��ģʽ����ͬ���޸�CC_Tool.bat
######2010/06/23  ������   �����г��ɶ�д�ļ�����ͬ���޸�CC_Tool.bat
######2010/07/01  ������   �޸ġ�ȥ��)ǰ��Ŀո�����)дΪ��(
######2010/07/02  ������   ,\;��ӿո���չ
######2010/07/05  ������   ȥ����ǰ��Ŀո� 
######2010/07/05  ������   ����ǿ������ת��
######2010/07/05  ������   ������궨��ȡ��ַ�е�ַ����&����ӿո�����
######2010/07/05  ������   �����߼����ʽ�н���==����дΪ��=���ģ���Ϊ���޸ģ�ֻ��ʾ
######2010/07/06  ������   ȡ������Ϊע��ʱ��Ƕ��ע�͵Ĵ���
######2010/07/06  ������   ��ͳ�ƺ�������ʾ���з���
######2010/07/07  ������   �����ж�ͷ�ļ������Ƿ�ʹ����""
######2010/07/07  ������   �����ж�switch��default�Ƿ����
######2010/07/08  ������   ע�͵���File $fileName is OK��������ͳ���Ѿ��������������
######2010/07/08  ������   ������if/for/while/switch���Ƿ�ֱ�ӽ�����{
######2010/07/12  ������   ����꺯�����Ų��걸��飺����һ�������Ƿ�ȫ����������
######2010/07/14  ������   ����"{"�Ƿ��ռһ�е��ж�
######2010/07/19  ������   ����궨��#defien  xx     xxx + xxx�����ŵ��ж�
######2010/07/20  ������   �������ע����ͳ�ƣ���������ֵ�ĸ澯
######2010/08/10  ������   ����ȫ�ֱ��������淶�Լ��-- g��ͷ������ʹ��int\short\char
######2010/08/10  ������   ����//ע�͵ļ�飬���ں���CheckGlobalVariable��
######2010/08/10  ������   ����һ���ж�����������������������ں���CheckGlobalVariable��
######2010/08/10  ������   �������Ƿ�ʹ����NULL�����ں���CheckGlobalVariable��
######2010/08/10  ������   ����ָ���δ���������ļ�飬��֧���βμ��
######2010/08/11  ������   �����ж�ͷ�ļ������Ƿ�淶
######2010/08/11  ������   ����δ�ڶ���ʱ��ʼ����ȫ�ֱ�����ͳ�ƣ���������ļ�UnInitVarInDef.txt
######2010/08/12  ������   ���淶�Լ����ͳһ������ļ�
######2010/08/30  ������   ����ָ�������������жϡ�����δ4�ı����Ŀ���
######2010/08/30  ������   ����ָ��������������Զ��޸�
######2010/08/31  ������   for (     ;
######2010/08/31  ������   ���ģʽ�¶ԡ�mac\inc�������
######2010/08/31  ������   �궨����еļ������
######2010/09/02  ������   (Uint)&start_cycle
######2010/09/13  ������   ȫ�ֳ����ļ���Ƿ�Ҫ��һ��
######2010/09/13  ������   ȥ����CHECK_LIST�����
######2010/11/25  ������   ����13�����Ӹ�ָ���ļ����
######2011/02/17  �ų��Ե������ļ��Ĺ淶�Լ��
######2011/02/17  ����forѭ������ʱ���ڡ�if/for/while/switch�Ƿ��������ͬһ�С�������
######2011/02/17  ������ӡ�в��ܳ���NULL�����⣻
######2011/04/02  ����CheckIn����
######2011/04/13  ȡ��CheckIn��UndoCheckout����ʱ���ļ���չ�����ж�

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
my $comment_line_cnt = 0;#ע������Ŀ
my $code_line_cnt    = 0;#��������Ŀ
my $comment_code_ratio = 0;#ע���� 
my $commCodeRatioTh    = 30;#ע��������ֵ���������޽��澯
my $dev_comment_line  = 0;
my $need_indent = 0; #������ʶ
my $check_indent_flag = 0; #�Ƿ��������������⣬1��飬0�����
my $check_ptrVar_flag = 0; #�Ƿ���ָ���������������⣬1��飬0�����
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


##������¼�ļ��ĵ�һ�С��ڶ��С����һ��
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
## ˵����Ϊͷ�ļ������ж���׼��
sub UpdataHeadFilePara()
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #ȥ������  
  
  #ֻ������Ч������
  if ($code_line !~ m{^\s*$})
  {
    #�����ļ��ڶ�����Ч�����У�ͷ�ļ�Ӧ���� #define MACE_MACRO_H
    if (($first_line_flag == 1) && ($second_line_flag == 0))
    {
      $second_line = $code_line;
      $second_line_flag = 1;
    } 
 
    #�����ļ���һ����Ч�����У�ͷ�ļ�Ӧ���� #ifndef MACE_MACRO_H
    if ($first_line_flag == 0)
    {
      $first_line = $code_line;
      $first_line_flag = 1;
    }
   
    
    #�����ļ����һ����Ч������
    $last_line = $code_line;
  }
}

##�����ж�ͷ�ļ������Ƿ�淶
## $Paramenter[0]: �ļ���
## ˵����
##      1. ��һ��ӦΪ#ifndef MAC_MACRO_H;
##      2. �ڶ���ӦΪ#define MAC_MACRO_H;
##      3. ���һ��ӦΪ#endif;
##      4. �ļ���Ϊmac_macro.h�����ӦΪMAC_MACRO_H��
##      ���Ϲ������C���Ա�̹淶��������ͷ�ļ�������ͷ(#ifndef �ļ���_H #define �ļ���_H);
sub CheckHeadFilePara()
{
  my @Paramenter=@_;
  my $define_file_name = 0;
  
  if ($Paramenter[0] =~ m{\.h})
  {
    $define_file_name = $Paramenter[0];
    $define_file_name =~ s{\.}{_}g;   #���ļ����õ�����
    
    if (($first_line !~ m{ifndef +($define_file_name)}i)
        || ($second_line !~ m{define +($define_file_name)}i)
        || ($last_line !~ m{\#endif}i))
    {
      print CCR_File  "  $Paramenter[0]����ȷ��ͷ�ļ������Ƿ�淶\n";
      print CCR_File  "$first_line\n$second_line\n$last_line\n";
      $unregu_flag = 1;
    }
  }
}

##�����жϴ�����������ȷ��
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
## ˵����1. $need_indent Ϊȫ�ֱ���
##       2. ����Ϊ4�ı���;
sub CheckIndent()
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #ȥ������
  
  if (($need_indent == 1) && ($check_indent_flag == 1))
  {
    if (($code_line !~ /^(( {4})|( {8})|( {12})|( {16})|( {20})|( {24})|( {28})|( {32})|( {36})|( {40})|( {44})|( {48})|( {52})|( {56})|( {60})|( {64}))[^ ]/)
    && ($code_line !~ m{^[^ ]})
    && ($code_line !~ m{^ *$}))
    {
      print CCR_File  "  $Paramenter[0], $line_cnt�У���ȷ�������Ƿ���ȷ\n";
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


##����ʵ�ֶԷ�ע�����в��淶�ո���޸�
## ˵����ֱ���޸�ȫ�ֱ���
sub RepairBlank()
{
  my @Paramenter=@_;
  my $code_line = $result;#�����޸�ǰ�Ĵ�����
  
  $result=~s{([A-Za-z0-9]|\)|\])(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[<]+=?|[%]=?|\*)([A-Za-z0-9_]|\(|\*)}{$1 $2 $3}g;
  $result=~s{([A-Za-z0-9]|\)|\])(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[<]+=?|[%]=?)([ ])([A-Za-z0-9_]|\(|\*)}{$1 $2$3$4}g;
  $result=~s{([A-Za-z0-9]|\)|\])([ ]+)(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[%]=?)([A-Za-z0-9_]|\(|\*)}{$1$2$3 $4}g;
  $result=~s{=( *)([&]|\*) *}{=$1$2}g;             #���� u8 *pu8Num =&u8Num; or u8 u8Num = * u8SfNum
  $result=~s{(\*)( *)(\))( *& *)}{$1$2$3&}g;    #���� (u8 *) &u32Num;
  if (!($result=~ m{\# ?incl}))                 #�ų�#include <mian>.h�����
  {
    $result=~s{([ ])([<]+=?)([A-Za-z0-9_]|\()}{$1$2 $3}g;
  }
  $result=~s{(for|if|switch|while)\(}{$1 \(}g;         #for( -> for (
  $result=~s{(;|,)([A-Za-z0-9_&*(])}{$1 $2}g;          #;,����ӿո�
  $result=~s{(\()( +)([A-Za-z0-9_&*]|\()}{$1$3}g;      #ȥ��(����Ŀո�
  $result=~s{([A-Za-z0-9_]|\)|\])( +)(\)|;|,)}{$1$3}g; #ȥ��")"��";"��","ǰ��Ŀո�
  $result=~s{u32(\)) +& +}{u32$1&}g;                   #����(u32) & u8Num
  $result=~s{(\*)( *)(\*)}{$1$3}g;                     #�޸�(XXX * *)->(XXX **)
  $result=~s{(^#define *[A-Za-z0-9_]* *)(- *)([A-Za-z0-9]|\()}{$1-$3}g; #PEBASE - 105 -> #PEBASE -105
  $result=~s{\[ *\* *}{[*}g;                           #�޸� [ * pu8Index] -> [*pu8Index]
  $result=~s{(^#define +[A-Za-z0-9_]+\([A-Za-z0-9_, ]+\) +)([&]|\*) +}{$1$2}g;##define MFUNC_GET_POINT(x)   &g_struMAC_RL_Info[x]
  $result=~s{(= +\([a-zA-Z_0-9]+\)) +(\*) +}{$1$2}g;   #����ǿ������ת��  
  $result =~ s{(^#define[^)]+\) +)& +}{$1&}g;#����ú궨��ȡ��ַ�е�ַ����&����ӿո�����

  if (   ($result=~m{=( *)([&]|\*) *})#���� u8 *pu8Num =&u8Num; or u8 u8Num = * u8SfNum
      || ($result=~m{(\*)( *)\) *([&]|\*) *})#���� (u8 *) &u32Num;
      || ($result=~m{(\*)( *)(\*)})#�޸�(XXX * *)->(XXX **)
      || ($result=~m{(\([a-zA-Z_0-9]+\)) *(\*|[&]) *})#����ǿ������ת�� 
      || ($result=~m{^#define +[A-Za-z0-9_]+ +[&] +[A-Za-z0-9_]+})
      || ($result=~m{\"})
      || ($result=~m{^ *(return) *[-]}))
  {
    $result = $code_line;
  }
  
  if ($code_line ne $result)
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У��Ƿ�ȱ�ٻ����ո�!\n";
    print CCR_File  "$code_line\n";
  }
  
  #���ָ�붨��ʱ��*�Ƿ����������
  if (($code_line =~ m{^ *(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ *\* +[a-zA-Z0-9_]+ *(;|\[|=)})
      && ($check_ptrVar_flag == 1))
  {
    $result =~ s{([^ ])([*])( +)([^ ])}{$1$3$2$4}g;        
  }
}


##����ʵ���ж�if������߼����ʽ�Ƿ񽫡�==����дΪ��=��
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
## ˵����$find_logical_if Ϊȫ�ֱ���
sub IsLogEquWrong()
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #ȥ������
  
  if ($find_logical_if == 1)
  {
    if ($code_line=~ m{\{|[;]})#ͨ�� { �ж��߼����ʽ�����Ѿ�����
    {
      $find_logical_if = 0;
    }
    else #����һ��һ�𶼻����߼����ʽ����
    {
      if ($code_line=~ m{[^=!><]=[^=]})
      {             
        print CCR_File  "  $Paramenter[0], $line_cnt�У������߼����ʽ�д��ڸ�ֵ��=������ȷ���Ƿ�����!\n";
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
        print CCR_File  "  $Paramenter[0], $line_cnt�У������߼����ʽ�д��ڸ�ֵ��=������ȷ���Ƿ�����!\n";
        print CCR_File  "    $code_line\n";
      }
      
      if ($code_line=~ m{\{|[;]})
      {
        $find_logical_if = 0;
      }            
    }
  }#End �����߼����ʽ�н���==����дΪ��=�����ж�
}


##����ʵ�ֺ꺯���в����Ƿ�����ŵļ��
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
## ˵�����ų��ú꺯���滻ԭ���������
##       0719����궨��#defien  xx     xxx + xxx�����ŵ��ж�
sub MacroBracket()
{
  my @Paramenter=@_;
  my $macro_line = $Paramenter[1]; 
  $macro_line =~ s{\n}{}g; #ȥ������
  
  ##�жϵ�ǰ���Ƿ��Ǻ꺯��������
  ##    �ų��ú꺯���滻ԭ���������
  if (($macro_line =~ m{define +[a-zA-Z0-9_]+\( *\b([a-zA-Z0-9_]+)\b})
      && ($macro_line !~ m{define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\) +[a-zA-Z0-9_]+ *\([a-zA-Z0-9, ]+\)})
      && ($macro_line !~ m{\[}))#($macro_line !~ m{define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\) +[a-zA-Z0-9_ .->\[\]]+$}))
  {
    ##��ȡ�꺯���ĵ�һ������
    $macro_x=$1;
    ##��ȡ�꺯���ĺ����岿��: �ָ�������$macro_array[1]
    @macro_array = split(/define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\)/, $macro_line);
    ##�жϺ꺯���������е�һ�������Ƿ����Ű�Χ
    if (($macro_array[1] =~ m{[^(\[] *\b($macro_x)\b}) 
        || ($macro_array[1] =~ m{\b($macro_x)\b *[^)\]]})
        || ($macro_line !~ m{define +[a-zA-Z0-9_]+\([a-zA-z0-9,_ ]+\) *(\(|\\)})
        || ($macro_line !~ m{(\)|\\) *$}))
    {
      print CCR_File  "  $Paramenter[0], $line_cnt�У���ȷ�Ϻ궨�������Ƿ��걸:\n";
      print CCR_File  "$macro_line\n";
      $unregu_flag = 1;
    }
    

  }
  
  ## �궨��#defien  xx     xxx + xxx�����ŵ��ж�
  if (($macro_line =~ m{define +[a-zA-Z0-9_]+ +[a-zA-Z0-9_]+ *[^a-zA-Z0-9_] *(=+|[!]=|[+]=?|-=?|[/]=?|[&]+=?|[|]+=?|[>]+=?|[<]+=?|\*)})
    || ($macro_line =~ m{define +[a-zA-Z0-9_]+ +-[0-9]}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У���ȷ�Ϻ궨�������Ƿ��걸:\n";
    print CCR_File  "$macro_line\n";  
    $unregu_flag = 1;    
  }
  
 
}

##�����ж�"{"�Ƿ��ռһ��
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
## ˵�����ų�����ֵ����ֵ�����
sub IsBigBracketSingleLine
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #ȥ������
  
  if (($code_line =~ m{\{}) && ($code_line !~ m{^\s*\{}) && ($code_line !~ m{= *\{}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У���ȷ�ϡ�{���Ƿ��ռһ��\n";
    print CCR_File  "$code_line\n";
    $unregu_flag = 1;
  }
  
}

##�����ж�if/for/while/switch�Ƿ��������ͬһ��
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
##  ˵�����ų���fp_ts��ʹ��while (1);�����
sub IsKeywordSingleLine
{
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #ȥ������
  
  #1.�ж�if/for/while/switch�Ƿ��������ͬһ��
  if (($code_line !~ m{while +\(1\);})
      && (($code_line =~ m{^ *(if|while|switch)[^a-zA-Z0-9_].*; *$}) || ($code_line =~ m{^ *(for).*;.*;.*; *$}))
      && ($code_line !~ m{\} *while}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt��, ��ȷ��if/for/while/switch�Ƿ��������ͬһ��\n";
    print CCR_File  "$code_line\n";
    $unregu_flag = 1;
  } 
}

##�����޸����ļ�·���е�б��ǰ��ӿո������
##    ��������ڲ�����ֱ���޸ı���$result
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

##�������ȫ�ֱ��������Ƿ�淶
## $Paramenter[0]: �ļ���
## $Paramenter[1]���ļ��е�ǰ�����(��ȥ��ע�Ͳ���)
##  ˵����ȫ�ֱ���������g_��ͷ���������岻��ʹ��int\short\char
sub CheckGlobalVariable
{ 
  my @Paramenter=@_;
  my $code_line = $Paramenter[1]; 
  $code_line =~ s{\n}{}g; #ȥ������
    
  #���ȫ�ֱ�������g��ͷ�����
  #---�ų���HL��Ŀ��ʹ��stru��ͷ�����
  if (($code_line =~ m{^(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ +\*?[a-fh-zA-Z_][a-zA-Z0-9_]+ *(;|\[|=)})
       && ($code_line !~ m{^(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ +\*?stru[a-zA-Z0-9_]+ *(;|\[|=)}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У�ȫ�ֱ��������Ƿ�淶:\n";
    print CCR_File  "$code_line\n";   
    $unregu_flag = 1;
  }
  
  #ͳһ���δ�ڶ���ʱ��ʼ����ȫ�ֱ������ļ�UnInitVarInDef.txt��
  if (($code_line =~ m{^(static +)?(const +)?[a-zA-Z0-9_]+ +\*?[a-zA-Z0-9_]+ *(;|\[|=)})
      && ($code_line !~ m{=}))
  {
    print UI_File "$Paramenter[0], $line_cnt��$code_line\n";
    $un_init_var_cnt++;
  }
  
  
  #���ʹ�� int\short\char�������������������ֲ�������ȫ�ֱ���������������βμ��
  if (($code_line =~ m{^ *(extern +)?(static +)?(const +)?(int|short|char) +\*?[a-zA-Z0-9_]+ *(;|\[|=)}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У���ֹʹ��int��short��char�������:\n";
    print CCR_File  "$code_line\n";     
  }
  
  # //��ע�ͼ��
  if ($code_line =~ m{\/\/})
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У���ֹʹ��\/\/����ע��:\n";
    print CCR_File  "$code_line\n";       
  }
  
  #һ���ж��������������������
  if ($code_line =~ m{^ *(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ +\*?[a-zA-Z0-9_]+ *, *\*? *[a-zA-Z0-9_]+ *(;|\[|=|,)})
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У����а���������������������\n";
    print CCR_File  "$code_line\n";      
  }
  
  #����Ƿ�ʹ��NULL
  if (($code_line =~ m{\b(NULL)\b})
      && ($code_line !~ m{\"}))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У���ֹʹ��NULL\n";
    print CCR_File  "$code_line\n";   
  }
  
  #���ָ�붨��ʱ��*�Ƿ����������
  if (($code_line =~ m{^ *(extern +)?(static +)?(const +)?[a-zA-Z0-9_]+ *\* +[a-zA-Z0-9_]+ *(;|\[|=)})
     && ($check_ptrVar_flag == 1))
  {
    print CCR_File  "  $Paramenter[0], $line_cnt�У�ָ���δ��������棺\n";
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
  
  $comment_line_cnt = 0;#ע������Ŀ
  $code_line_cnt    = 0;#��������Ŀ
  $comment_code_ratio = 0;#ע����
  
  $first_line_flag = 0;#ÿ���ļ���ʼʱ���ʼ��
  $second_line_flag = 0;#ÿ���ļ���ʼʱ���ʼ��
  
  
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
    #����ע���ص������
    if (($Out_line=~m{\*/ */\*}) && ($Out_line=~m{\*/}))
    {
      $Out_line=~s{\*/ */\*}{  }g;#�޸��ص�ע�͵��滻��ʽ
    }
    
    
    if (0 == $Start_valid)
    {   
      if ($Out_line=~m{/\*})
      {
        $Start_valid=1;
        @array=split(m{/\*}, $Out_line);
        $result=$array[0];
               
        &RepairBlank($fileName, $result);
                        
        #ͳ��switch��Ŀ
        if ($result =~ m{switch *\(})
        {
          $switch_cnt++;
        }
        
        #ͳ��default��Ŀ
        if ($result =~ m{default *:})
        {
          $s_default_cnt++;
        }
        
        #ͳ��һ���Ƿ���������䣬ͨ��;���ж�
        if (($result =~ m{;.*; *$})
            && ($result !~ m{^ *(for)}))
        {
          print CCR_File  "  $fileName, $line_cnt, �Ƿ����ж����䣺\n";
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
        
        #ͳ��switch��Ŀ
        if ($result =~ m{switch *\(})
        {
          $switch_cnt++;
        }
        
        #ͳ��default��Ŀ
        if ($result =~ m{default *:})
        {
          $s_default_cnt++;
        }
        
        #ͳ��һ���Ƿ���������䣬ͨ��;���ж�
        if (($result =~ m{;.*; *$})
            && ($result !~ m{^ *(for)})
            && ($result !~ m{\"}))
        {
          print CCR_File  "  $fileName, $line_cnt, �Ƿ����ж����䣺\n";
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

    #ɾ��TAB�������������Ļ
    if ($Out_line =~ m{\t})
    {
      print CCR_File  "  $fileName, $line_cnt: ������Tab��.\n";
      $Out_line =~ s{\t}{    }g;
    }
    
    #ɾ����β�ո�
    $Out_line=~s{ +$}{}g;
    
    
    #ȡ������Ϊע��ʱ��Ƕ��ע�͵Ĵ���     
    if (($In_line =~ m{^ */\*}) && ($In_line =~ m{\*/ */\*}))
    {
      $Out_line = $In_line;
    }
    
    #���ͷ�ļ������Ƿ���Ϲ淶
    if ($Out_line =~ m{(^#include +\")})
    {
      print CCR_File  "  $fileName, $line_cnt, ��ȷ��ͷ�ļ������Ƿ���Ϲ淶��\n";
      print CCR_File  "$Out_line";
    }
    
    #��ʶ�Ƿ����˸ı�
    if (!($Out_line eq $In_line))
    {
      $Modify_Flag=1;    
    }
    print Output "$Out_line";
  }
  
  if ($switch_cnt != $s_default_cnt)
  {
    print CCR_File  "  $fileName, 'switch'�Ƿ���'default'���: $switch_cnt,$s_default_cnt\n";
  }
  
  #����ע����
  if (($code_line_cnt + $comment_line_cnt) == 0)
  {
    $comment_code_ratio = 111;
  }
  else
  {
    $comment_code_ratio = $comment_line_cnt * 100 / ($code_line_cnt + $comment_line_cnt);
  }
  
  #ע���ʵ�������ֵ����澯
  if($comment_code_ratio < $commCodeRatioTh)
  {
    $dev_comment_line = $commCodeRatioTh / (100 - $commCodeRatioTh)* $code_line_cnt - $comment_line_cnt;
    print CCR_File  "  $fileName, �ļ�ע����Ϊ$comment_code_ratio%�������!! ����$dev_comment_line��ע�Ϳɴﵽ��׼ע����$commCodeRatioTh%\n";
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
  

  #�ų�����Ҫ���ĵ������ļ�
  $is_third_party_file = 0;

  @get_third_party_files_dir = split("dir.pl", $0);
  # �õ�branch_name.txt��·��
  $third_party_files = $get_third_party_files_dir[0]."/third_party_files.txt";
  
  open(THIRD_PARTY_FILES, $third_party_files);
  
  while (defined ($third_party_file_name = <THIRD_PARTY_FILES>))
  {
    $third_party_file_name =~s{\n}{}g;
    if ($file =~m{$third_party_file_name})
    {
      print "$third_party_file_name���ڵ������ļ�������Ҫ���й淶�Լ��.\n";
      #print "$file, \n";
      $is_third_party_file = 1;
      last;
    }
  }
   
  close THIRD_PARTY_FILES;
  
  if ($is_third_party_file == 1)
  {
    #print "�����������ļ���������һ�ļ���\n";
    return;
  }
  #End�ų�����Ҫ���ĵ������ļ�
  

  
  $pfile_name=$file;
  $pfile_name=~s{(.+)(\/)([A-Za-z0-9_]+\.)([a-zA-Z0-9]+)$}{$3$4}g;

  if (-f $pfile_name)
  { 
    #1: ��View������.c\.h�ļ�(�ǡ�ֻ�����ļ�)�淶���޸�; 
    if (($ARGV[0] eq "CR_Mode1") && ($file =~ m{\.(c|h)$}) && (-w $pfile_name))
    {
      &FileModify($file);
      $filecnt++;
    }
    
    #2: �������ָ���ļ����й淶���޸�;
    if (($ARGV[0] eq "CR_Mode2") && ($ARGV[1] eq $pfile_name) && (-w $pfile_name))
    {
      print "��ָ�����ļ��Ѿ��ҵ������ڽ��д���.\n";
      &FileModify($file);
      $filecnt++;
    }
    
    #3: ��View������.c\.h�ļ�(����ֻ�����ļ�)�淶�Լ��; 
    if (($ARGV[0] eq "CR_Mode3") && ($file =~ m{\.(c|h)$}))
    {
      &FileModify($file);
      $filecnt++;
    }
    
    #4: �������ָ���ļ����й淶�Լ��;
    if (($ARGV[0] eq "CR_Mode4") && ($ARGV[1] eq $pfile_name))
    {
      print "��ָ�����ļ��Ѿ��ҵ������ڽ��д���.\n";
      &FileModify($file);
      $filecnt++;
    }
    
    #��Checkout���ļ���꣬ʵ�ʸ��ǡ�ֻ�������ļ����
    if(($ARGV[0] eq "CO_Label") && (-w $pfile_name))
    {
      $label_name = $ARGV[1];
      system("cleartool mklabel -replace $label_name $pfile_name");
      $filecnt++;
    }
    
    #�г��ɶ�д�ļ�
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
    
    #��ָ���ļ����
    if(($ARGV[0] eq "SpeF_Label") && ($ARGV[1] eq $pfile_name))
    {
      $label_name = $ARGV[2];
      system("cleartool mklabel -replace $label_name $pfile_name");
      $filecnt++;
    }  
    
    #TDCUP�����ڴ����B��
    if(($ARGV[0] eq "APPLY_TDCUP_V4_B_LABEL") && (-w $pfile_name))
    {
    	#PLP�ļ����
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
    	#BCPE1�ļ����
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

#��ȡUnInitVarInDef.txt�ļ�ȫ·����
@get_file_dir = split("dir", $0);
$unInit_file = $get_file_dir[0]."UnInitVarInDef.txt";
$codeCheckReport_file =  $get_file_dir[0]."CodeCheckReport.txt";

open(UI_File, "> $unInit_file");#���ļ�UnInitVarInDef.txt
print UI_File "  ���±���δ�ڶ���ʱ��ʼ������Ҫȷ���Ƿ�ͳһ�����˳�ʼ����\n";#������ļ�UnInitVarInDef.txt

open(CCR_File, "> $codeCheckReport_file");#���ļ�CodeCheckReport.txt
print CCR_File "  ���¹淶��������Ҫȷ�ϣ�\n";

find(\&DirProcess, "."); #������ǰĿ¼�������ļ����в���

close UI_File; #�ر��ļ�UnInitVarInDef.txt
close CCR_File;#�ر��ļ�CodeCheckReport.txt


#1: ��View������.c\.h�ļ�(�ǡ�ֻ�����ļ�)�淶���޸�; 
if (($ARGV[0] eq "CR_Mode1") || ($ARGV[0] eq "CR_Mode2"))
{
  print "�����$filecnt���ļ�����$unstandard_file_cnt���ļ������˹淶���޸ġ�\n";
}

#3: ��View������.c\.h�ļ�(����ֻ�����ļ�)�淶�Լ��;
if (($ARGV[0] eq "CR_Mode3") || ($ARGV[0] eq "CR_Mode4"))
{
  print "�����$filecnt���ļ���$unstandard_file_cnt���ļ����ڿո����⣬���Զ��޸ġ�\n";
  print "   �����淶��������ļ���CodeCheckReport.txt";
  
  #��ʾδ�ڶ���ʱ��ʼ���ı���
  if ($un_init_var_cnt != 0)
  {
    system("$unInit_file");
  }
  
  #��ʾ���ܴ��ڵĹ淶������
  system("$codeCheckReport_file");
}

#��Checkout���ļ���꣬ʵ�ʸ��ǡ�ֻ�������ļ����
if(($ARGV[0] eq "CO_Label") && (-w $pfile_name))
{
  print "����$filecnt���ļ���꣺$label_name\n";
}

#�г��ɶ�д�ļ�
if(($ARGV[0] eq "LSCO_Mode2") && (-w $pfile_name))
{
  print "�ҵ�$filecnt���ɶ�д.c/.h�ļ���\n";
}

#undo checkout
if ($ARGV[0] eq "UN_CO_Y")
{
  print "����$filecnt���ļ�����Undo Checkout����\n";
}

#��Ļ��ʾһ���ո�
print "\n";
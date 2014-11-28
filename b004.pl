#月の名前の配列
local @monthName =
  split( ",", "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec" );

main();
exit;

#実行部分
sub main
{

	#検索キーとなるipアドレスを入力
	local $line = <STDIN>;
	chomp($line);
	local @baseAry = split( "\\.", $line );

	#検索対象のデータ件数を入力
	local $logNum = <STDIN>;
	chomp($logNum);

	#検索対象のデータを格納
	local @dataAry = ();
	local $cnt;

	for ( $cnt = 0 ; $cnt < $logNum ; $cnt++ )
	{

		#検索対象のデータを入力
		$line = <STDIN>;
		chomp($line);

		#オブジェクトに変換して格納
		my %dat = getDataObj($line);
		push( @dataAry, \%dat );
	}

	#検索対象データを日付で昇順ソート
	my @sortData =
	  sort { getCorrectTime( $$a{time} ) cmp getCorrectTime( $$b{time} ) }
	  @dataAry;

	#検索する
	for ( $cnt = 0 ; $cnt <= $#sortData ; $cnt++ )
	{
		local $data = $sortData[$cnt];
		local @qAry = split( "\\.", $$data{ip} );

		local $okCount = 0;
		for ( local $i = 0 ; $i <= $#qAry ; $i++ )
		{
			local $q = $qAry[$i];
			local $b = $baseAry[$i];

			#* または同一の場合
			if ( $b eq "*" || $b eq $q )
			{
				$okCount++;
			}

			#範囲指定の場合
			elsif ( $b =~ /^\[(\d+)\-(\d+)\]$/ )
			{

				local $num1 = $1 * 1;
				local $num2 = $2 * 1;
				local $qNum = $q * 1;

				if ( $num1 <= $qNum && $qNum <= $num2 )
				{
					$okCount++;
				}
			}
		}

		#一致するものを表示する
		if ( $okCount == 4 )
		{
			print "$$data{ip} $$data{time} $$data{url}\n";
		}
	}
}

#入力データ文字列をオブジェクトに変換する
sub getDataObj
{
	my $line = shift;
	my %ret  = ();

	my @ary = split( " ", $line );

	$ret{ip} = $ary[0];

	$ret{url} = $ary[6];

	my $time = $ary[3];

	$time =~ s/^\[//;
	$ret{time} = $time;

	return %ret;
}

#日付をソートできるように変換して返す
sub getCorrectTime
{
	my $str = shift;    #08/Jul/2013:16:55:14
	$str =~ /(\d+)\/(.+)\/(\d+)\:(\d+)\:(\d+)\:(\d+)/;

	my ( $date, $month, $year, $hour, $minute, $sec ) =
	  ( $1, $2, $3, $4, $5, $6 );

	$month = convertMonth($month);

	return "$year/$month/$date:$hour:$minute:$sec";
}

#月の名前→数字に変換して返す
sub convertMonth
{
	my $str = shift;

	for ( my $i = 0 ; $i <= $#monthName ; $i++ )
	{
		if ( $str eq $monthName[$i] )
		{
			return sprintf( "%02d", $i + 1 );
		}
	}
	return "00";
}

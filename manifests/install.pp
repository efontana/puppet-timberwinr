define timberwinr::install(  
  $version = '1.2.209',
  $sourceurl='http://www.ericfontana.com/TimberWinR',
  $installdir='C:\TimberWinR',
  $temp_target='C:\temp',
  $timeout = 500,
  $diagnostics_port=5142,
)
{
  Exec{
      tries     => 3,
      try_sleep => 30,
      timeout   => 500,
    }
  
  $msi_name = "TimberWinR-${version}.0.msi"
  $sourcelocation="${sourceurl}/${msi_name}"
  $confd = "${installdir}\\conf.d"
  $logdir = "${installdir}\\logs"
  
  file { "${installdir}" : 
    ensure => "directory"
  }  
    
  file { "${$logdir}" : 
    ensure => "directory"
  }
  
  file { "${$confd}" : 
    ensure => "directory"
  }
   
  file { "${temp_target}":
    ensure => "directory"
  }
  
  if $diagnostics_port != 0 { 
      windows_firewall { 'TCP DiagPort Port':
      ensure => present,
      ports => "[${diagnostics_port}]",
  }
  
  file { "${confd}\\input_windows_events.json":
	ensure => file,
	source => 'puppet:///modules/vp_timberwinr/input_windows_events.json',       
  }
	
  $target_file = "${temp_target}\\${msi_name}"  
  $base_cmd = '$wc = New-Object System.Net.WebClient;'
  $cmd = "${base_cmd}\$wc.DownloadFile('${sourcelocation}','${target_file}')"
 
  notice("Downloading $sourcelocation")  
    
  exec{"Download-${target_file}":
    require   => File["${temp_target}"],
      provider  => powershell,
      command   => $cmd,
      unless    => "if(Test-Path -Path \"${target_file}\" ){ exit 0 }else{exit 1}",
      timeout   => $timeout,
  }->  
  package { 'TimberWinR':
    source => "${target_file}",
    ensure => installed,
    require => Exec["Download-${target_file}"],
    install_options => ["TARGETDIR=${installdir}","INSTALLFOLDER=${installdir}","CONFIGFILE=${confd}","LOGDIR=${logdir}","DIAGPORT=${diagnostics_port}",'/qn'],    
  }  
}

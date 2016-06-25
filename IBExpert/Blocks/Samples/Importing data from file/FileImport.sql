set names win1251;
set sql dialect 3;
set clientlib 'C:\Program Files\Firebird\bin\fbclient.dll';

create database 'localhost/3060:D:\allscripts.fdb'
user 'SYSDBA' password 'masterkey'
page_size 8192 default character set WIN1251;

create generator gen_script_id;

create table scripts (
  ID INTEGER NOT NULL PRIMARY KEY,
  FILENAME VARCHAR(2000),
  SCRIPT_TEXT BLOB sub_type text);

create trigger script_bi for scripts
active before insert position 0
as
begin
  if (new.id is null) then
    new.id = gen_id(gen_script_id, 1);
end;

execute ibeblock
as
begin
  ibec_progress('Searching for script files...');
  files_count = ibec_getfiles(files_list, 'D:\', '*.sql', __gfRecursiveSearch + __gfFullName);

  if (files_count > 0) then
  begin
    i = 0;
    while (i < ibec_high(files_list)) do
    begin
      file_name = files_list[i];
      if (ibec_filesize(file_name) < 10240000) then
      begin
        script_data = ibec_loadfromfile(file_name);
        ibec_progress('Adding script file ' || :file_name);
        insert into scripts (filename, script_text) values (:file_name, :script_data);
        commit;
      end
      i = i + 1;
    end
  end
end;

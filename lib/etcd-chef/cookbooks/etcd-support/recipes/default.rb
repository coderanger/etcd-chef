require 'etcd'
$:.unshift(File.expand_path('../../../../..', __FILE__))
require 'etcd-chef'

run_context.etcd_client = Etcd.client
begin
  watch_val = run_context.etcd.watch('/', run_context.etcd_index)
  run_context.etcd_index = watch_val.index
rescue SystemExit
  raise EtcdChef::AbortWatch
end

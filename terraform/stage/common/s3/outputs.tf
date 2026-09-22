output "frontend_bucket_id" {
  value = module.s3_for_logs_frontend.s3_bucket_id

}
output "backend_bucket_id" {
  value = module.s3_for_logs_backend.s3_bucket_id
}

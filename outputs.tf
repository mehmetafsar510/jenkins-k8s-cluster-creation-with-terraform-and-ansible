output "kube-master-ip" {
  value       = module.compute.kube-master-ip
  sensitive   = false
  description = "public ip of the kube-master"
}

output "worker-1-ip" {
  value       = module.compute.worker-1-ip
  sensitive   = false
  description = "public ip of the worker-1"
}

output "worker-2-ip" {
  value       = module.compute.worker-2-ip
  sensitive   = false
  description = "public ip of the worker-2"
}
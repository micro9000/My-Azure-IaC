resource "azuredevops_agent_pool" "selfhosted-agent-pool" {
  name           = var.azure-do-agent-pool-name
  auto_provision = false
  auto_update    = false
}

data "azuredevops_project" "devops-project" {
  name = var.azure-do-project-name
}

resource "azuredevops_agent_queue" "selfhosted-agent-to-project" {
  project_id    = data.azuredevops_project.devops-project.id
  agent_pool_id = azuredevops_agent_pool.selfhosted-agent-pool.id
}

# Manage pipeline access permissions to resources.
resource "azuredevops_pipeline_authorization" "example" {
  project_id  = data.azuredevops_project.devops-project.id
  resource_id = azuredevops_agent_queue.selfhosted-agent-to-project.id
  type        = "queue"
}
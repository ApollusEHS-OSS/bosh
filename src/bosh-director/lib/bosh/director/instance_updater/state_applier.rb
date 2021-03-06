module Bosh::Director
  class InstanceUpdater::StateApplier
    def initialize(instance_plan, agent_client, rendered_job_templates_cleaner, logger, options)
      @instance_plan = instance_plan
      @instance = @instance_plan.instance
      @agent_client = agent_client
      @rendered_job_templates_cleaner = rendered_job_templates_cleaner
      @logger = logger
      @is_canary = options.fetch(:canary, false)
    end

    def apply(update_config, wait_for_running = true)
      @instance.apply_vm_state(@instance_plan.spec)
      @instance.update_templates(@instance_plan.templates)
      @rendered_job_templates_cleaner.clean

      start(update_config, wait_for_running) if @instance.state == 'started'
    end

    private

    def start(update_config, wait_for_running)
      Starter.start(
        instance: @instance,
        agent_client: @agent_client,
        update_config: update_config,
        is_canary: @is_canary,
        wait_for_running: wait_for_running,
        logger: @logger,
      )
      @instance.update_state
    end
  end
end

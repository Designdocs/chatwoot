class EnableCaptainForSelfHostedAccounts < ActiveRecord::Migration[7.2]
  def up
    return unless ChatwootApp.enterprise?
    return if ChatwootApp.chatwoot_cloud?

    Account.find_each do |account|
      account.enable_features('captain_integration', 'captain_tasks', 'custom_tools')
      account.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Captain feature preferences may have changed since activation'
  end
end

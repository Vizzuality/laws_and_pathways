class AddCoalMiningSectorCluster < ActiveRecord::Migration[6.1]
  def change
    energy = TPISectorCluster.where(name: 'Energy').first
    return unless energy

    coal_mining = TPISector.where(name: 'Coal Mining').first
    return unless coal_mining

    coal_mining.update(cluster_id: energy.id)
  end
end

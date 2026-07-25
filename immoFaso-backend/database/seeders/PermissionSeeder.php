<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
/**
 * Seeder pour les permissions
 */
class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        // Créer les permissions
        $permissions = [
            'publier_annonce',
            'modifier_annonce',
            'supprimer_annonce',
            'envoyer_demande_location',
            'valider_demande_location',
            'voir_paiements',
            'valider_paiement',
            'gerer_utilisateurs',
        ];

        foreach ($permissions as $permission) {
            Permission::create(['name' => $permission]);
        }

        // Recupérer ou créer les rôles
        $admin = Role::findOrCreate("ADMIN","web");
        $locataire = Role::findOrCreate("LOCATAIRE","api");
        $proprietaire = Role::findOrCreate("PROPRIETAIRE","api");

        // Assigner les permissions aux rôles
        $locataire->givePermissionTo([
            'envoyer_demande_location',
            'voir_paiements',
        ]);

        $proprietaire->givePermissionTo([
            'publier_annonce',
            'modifier_annonce',
            'supprimer_annonce',
            'valider_demande_location',
            'voir_paiements',
        ]);

        // Admin a tout
        $admin->givePermissionTo(Permission::all());
    }
}

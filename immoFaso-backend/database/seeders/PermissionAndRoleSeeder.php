<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
/**
 * Seeder pour les permissions
 */
class PermissionAndRoleSeeder extends Seeder
{
    public function run(): void
{
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

    // Créer les permissions pour le guard 'api' (locataire, proprietaire)
    foreach ($permissions as $permission) {
        Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'api']);
    }

    // Créer les permissions pour le guard 'web' (admin)
    foreach ($permissions as $permission) {
        Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'web']);
    }

    // Rôles
    $admin = Role::findOrCreate('ADMIN', 'web');
    $locataire = Role::findOrCreate('LOCATAIRE', 'api');
    $proprietaire = Role::findOrCreate('PROPRIETAIRE', 'api');

    // Assignation (guard 'api')
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

    // Assignation (guard 'web')
    $admin->givePermissionTo(Permission::where('guard_name', 'web')->get());
}
}

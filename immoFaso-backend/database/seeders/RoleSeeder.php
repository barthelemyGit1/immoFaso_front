<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Creation des roles pour les utilisateurs
     */
    public function run(): void
    {
        Role::create(["name"=>"ADMIN","guard_name"=>"web"]);
        Role::create(["name"=>"PROPRIETAIRE","guard_name"=>"api"]);
        Role::create(["name"=>"LOCATAIRE","guard_name"=>"api"]);
    }
}

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('utilisateurs', function (Blueprint $table) {
    $table->uuid('id')->primary();

    $table->string('nom');
    $table->string('prenom');

    $table->string('telephone')->unique();
    $table->string('email')->nullable()->unique();

    $table->string('password');

    $table->boolean('telephone_verifie')->default(false);

    $table->enum('statut', [
        'actif',
        'suspendu',
        'supprime'
    ])->default('actif');

    $table->rememberToken();
    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('utilisateurs');
    }
};

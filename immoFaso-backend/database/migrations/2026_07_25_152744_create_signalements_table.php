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
        Schema::create('signalements', function(Blueprint $table){

    $table->uuid('id')->primary();

    $table->foreignUuid('id_auteur')
        ->constrained('utilisateurs');


    $table->text('motif');

    $table->enum('statut',[
        'en_attente',
        'traite',
        'rejete'
    ])->default('en_attente');

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('signalements');
    }
};

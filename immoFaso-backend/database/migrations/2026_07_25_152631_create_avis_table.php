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
        Schema::create('avis', function(Blueprint $table){

    $table->uuid('id')->primary();

    $table->foreignUuid('id_auteur')
        ->constrained('utilisateurs');

    $table->foreignUuid('id_cible')
        ->constrained('utilisateurs');

    $table->tinyInteger('note');

    $table->text('commentaire')->nullable();

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('avis');
    }
};

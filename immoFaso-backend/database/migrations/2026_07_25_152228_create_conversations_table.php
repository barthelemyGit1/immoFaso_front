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
        Schema::create('conversations', function(Blueprint $table){

    $table->uuid('id')->primary();

    $table->foreignUuid('id_annonce')
        ->constrained('annonces')
        ->cascadeOnDelete();

    $table->foreignUuid('id_locataire')
        ->constrained('utilisateurs');

    $table->foreignUuid('id_proprietaire')
        ->constrained('utilisateurs');

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};

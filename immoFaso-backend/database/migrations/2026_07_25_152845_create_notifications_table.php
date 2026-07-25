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
        Schema::create('notifications', function(Blueprint $table){

    $table->uuid('id')->primary();

    $table->foreignUuid('id_user')
        ->constrained('utilisateurs')
        ->cascadeOnDelete();

    $table->string('type');

    $table->text('contenu');

    $table->boolean('lu')->default(false);

    $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};

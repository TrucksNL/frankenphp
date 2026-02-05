<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

final class HomeController extends AbstractController
{
    #[Route(path: '/', name: 'app.home.index')]
    public function index(): JsonResponse
    {
        return $this->json([
            'status' => 'success',
            'message' => 'Hello world!',
        ]);
    }
}

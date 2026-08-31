<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
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

    #[Route(path: '/phpinfo', methods: [Request::METHOD_GET])]
    public function phpinfo(): Response
    {
        ob_start();
        phpinfo();
        ob_flush();

        $content = ob_get_contents();
        return new Response($content);
    }
}

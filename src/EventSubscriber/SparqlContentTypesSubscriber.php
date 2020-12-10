<?php

declare(strict_types = 1);

namespace Drupal\sparql_entity_storage\EventSubscriber;

use Drupal\sparql_entity_storage\Encoder\SparqlEncoder;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\HttpKernel\Event\GetResponseEvent;
use Symfony\Component\HttpKernel\KernelEvents;

/**
 * Event subscriber for adding RDF content types to the request.
 */
class SparqlContentTypesSubscriber implements EventSubscriberInterface {

  /**
   * Register content type formats on the request object.
   *
   * @param \Symfony\Component\HttpKernel\Event\GetResponseEvent $event
   *   The Event to process.
   */
  public function onKernelRequest(GetResponseEvent $event) {
    /** @var \EasyRdf\Format $format */
    foreach (SparqlEncoder::getSupportedFormats() as $format) {
      $mime = array_keys($format->getMimeTypes());
      $event->getRequest()->setFormat($format->getName(), $mime);
    }
  }

  /**
   * {@inheritdoc}
   */
  public static function getSubscribedEvents() {
    $events[KernelEvents::REQUEST][] = ['onKernelRequest'];
    return $events;
  }

}

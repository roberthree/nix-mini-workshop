import sys
import pygame

# --- Config ---
WIDTH, HEIGHT = 640, 400
RADIUS = 20
SPEED = 240.0  # pixels per second


def clamp(v, lo, hi):
    return max(lo, min(hi, v))


def main():
    pygame.init()
    try:
        screen = pygame.display.set_mode((WIDTH, HEIGHT))
    except Exception as e:
        print("Could not open a display:", e)
        sys.exit(1)

    pygame.display.set_caption("Move the ball with arrow keys (ESC to quit)")
    clock = pygame.time.Clock()

    x, y = WIDTH // 2, HEIGHT // 2
    running = True
    while running:
        dt = clock.tick(60) / 1000.0  # seconds since last frame (~60 FPS)

        # Events
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                running = False

        # Continuous input
        keys = pygame.key.get_pressed()
        dx = (keys[pygame.K_RIGHT] - keys[pygame.K_LEFT]) * SPEED * dt
        dy = (keys[pygame.K_DOWN] - keys[pygame.K_UP]) * SPEED * dt

        x += dx
        y += dy

        # Clamp so the full ball remains visible
        x = clamp(x, RADIUS, WIDTH - RADIUS)
        y = clamp(y, RADIUS, HEIGHT - RADIUS)

        # Draw
        screen.fill((30, 30, 30))
        pygame.draw.circle(screen, (0, 200, 255), (int(x), int(y)), RADIUS)
        pygame.display.flip()

    pygame.quit()
    sys.exit(0)


if __name__ == "__main__":
    main()

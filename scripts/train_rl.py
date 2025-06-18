import torch
import gymnasium as gym
import mani_skill.envs
from tqdm import tqdm
from my_lib.my_package.my_module import my_function


if __name__ == "__main__":
    print(f"CUDA Available : {torch.cuda.is_available()}")
    sim_backend = "gpu"
    render_backend = "gpu"

    env = gym.make(
        "PickCube-v1",
        obs_mode="state",
        control_mode="pd_joint_delta_pos",
        num_envs=16,
        sim_backend=sim_backend,
        render_backend=render_backend
    )
    print(env.observation_space)
    print(env.action_space)

    print(my_function())

    obs, _ = env.reset(seed=0)
    for i in tqdm(range(200)):
        action = env.action_space.sample()
        obs, reward, terminated, truncated, info = env.step(action)
        done = terminated | truncated
    env.close()

    print("SUCCESS: Training done!")
